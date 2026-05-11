import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.Pipewire
import "."

Item {
    id: leftRoot

    function toggleLeft() {
        leftOSDWindow.visible = !leftOSDWindow.visible
    }

    function formatTime(seconds) {
        if (isNaN(seconds) || seconds < 0) {
            return "0:00"
        }
        let m = Math.floor(seconds / 60)
        let s = Math.floor(seconds % 60)
        return m + ":" + (s < 10 ? "0" : "") + s
    }

    // ==========================================
    // 1. LEFT DASHBOARD WINDOW
    // ==========================================
    PanelWindow {
        id: leftOSDWindow
        visible: false 
        
        exclusionMode: ExclusionMode.Ignore 
        
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        
        anchors { 
            top: true
            bottom: true
            left: true
            right: true
        }
        
        color: "transparent"

        MouseArea {
            anchors.fill: parent
            onClicked: {
                leftOSDWindow.visible = false
            }
        }

        Rectangle {
            id: leftBg
            width: 420
            anchors { 
                left: parent.left
                top: parent.top
                bottom: parent.bottom 
            }
            anchors.margins: 20
            
            color: Qt.alpha(Colors.bg0, 0.95)
            border.color: Colors.bg2
            border.width: 2
            radius: 15
            
            MouseArea { 
                anchors.fill: parent 
            }

            focus: true
            
            Keys.onEscapePressed: {
                leftOSDWindow.visible = false
            }
            
            onVisibleChanged: { 
                if (visible) {
                    leftBg.forceActiveFocus()
                    generateCalendar()
                }
            }

            // ==========================================
            // STATE PROPERTIES
            // ==========================================
            property int briPercent: 50
            property string mediaStatus: "Stopped"
            property string mediaTitle: "No Media Playing"
            property string mediaArtist: ""
            property string mediaArt: ""
            property real mediaLength: 0
            property real mediaPosition: 0

            // ==========================================
            // CALENDAR LOGIC
            // ==========================================
            ListModel { 
                id: calendarModel 
            }
            
            function generateCalendar() {
                calendarModel.clear()
                let today = new Date()
                let currentMonth = today.getMonth()
                let currentYear = today.getFullYear()
                let currentDate = today.getDate()
                
                let firstDay = new Date(currentYear, currentMonth, 1).getDay()
                let daysInMonth = new Date(currentYear, currentMonth + 1, 0).getDate()
                
                for (let i = 0; i < 42; i++) {
                    let dayNum = i - firstDay + 1
                    let isCurrentMonth = dayNum > 0 && dayNum <= daysInMonth
                    let isToday = isCurrentMonth && dayNum === currentDate
                    
                    let displayNum = ""
                    if (isCurrentMonth) {
                        displayNum = dayNum.toString()
                    } else if (dayNum <= 0) {
                        displayNum = (new Date(currentYear, currentMonth, 0).getDate() + dayNum).toString()
                    } else {
                        displayNum = (dayNum - daysInMonth).toString()
                    }

                    calendarModel.append({
                        "dayText": displayNum,
                        "isCurrentMonth": isCurrentMonth,
                        "isToday": isToday
                    })
                }
            }

            Component.onCompleted: {
                generateCalendar()
            }

            // ==========================================
            // MEDIA LOGIC (Exactly from your snippet)
            // ==========================================
            Timer {
                id: mediaPollTimer
                interval: 1000 
                running: true
                repeat: true
                onTriggered: { 
                    if (!mediaWatcher.running) {
                        mediaWatcher.running = true
                    }
                    if (leftBg.mediaStatus === "Playing" && !mediaPosWatcher.running) {
                        mediaPosWatcher.running = true
                    }
                }
            }

            Process {
                id: mediaWatcher
                command:[
                    "playerctl", 
                    "metadata", 
                    "--format", 
                    "{{status}}||{{title}}||{{artist}}||{{mpris:artUrl}}||{{mpris:length}}"
                ]
                stdout: SplitParser {
                    onRead: data => {
                        let parts = data.split("||")
                        if (parts.length >= 5) {
                            leftBg.mediaStatus = parts[0].trim()
                            leftBg.mediaTitle = parts[1].trim() || "Unknown Title"
                            leftBg.mediaArtist = parts[2] ? parts[2].trim() : "Unknown Artist"
                            leftBg.mediaArt = parts[3] ? parts[3].trim() : ""
                            
                            let len = parseInt(parts[4].trim())
                            leftBg.mediaLength = isNaN(len) ? 0 : (len / 1000000.0)
                        }
                    }
                }
                onExited: (code) => {
                    if (code !== 0) {
                        leftBg.mediaStatus = "Stopped"
                        leftBg.mediaTitle = "No Media Playing"
                        leftBg.mediaArtist = ""
                        leftBg.mediaArt = ""
                        leftBg.mediaLength = 0
                        leftBg.mediaPosition = 0
                    }
                }
            }

            Process {
                id: mediaPosWatcher
                command:[
                    "playerctl", 
                    "position"
                ]
                stdout: SplitParser {
                    onRead: data => {
                        let pos = parseFloat(data.trim())
                        if (!isNaN(pos) && !mediaProgress.pressed) {
                            leftBg.mediaPosition = pos
                        }
                    }
                }
            }

            // ==========================================
            // AUDIO & BRIGHTNESS LOGIC
            // ==========================================
            PwObjectTracker { 
                id: pwTracker
                objects: Pipewire.defaultAudioSink ? [Pipewire.defaultAudioSink] :[] 
            }
            
            property var audio: Pipewire.defaultAudioSink?.audio
            property int volPercent: audio ? Math.round(audio.volume * 100) : 0

            Timer { 
                interval: 2000
                running: !briSlider.pressed
                repeat: true
                onTriggered: {
                    getBri.running = true
                } 
            }

            Process {
                id: getBri
                command:[
                    "brightnessctl", 
                    "-m"
                ]
                stdout: SplitParser { 
                    onRead: data => { 
                        let parts = data.split(",")
                        if (parts.length >= 4 && !briSlider.pressed) {
                            leftBg.briPercent = parseInt(parts[3].replace("%", ""))
                        }
                    } 
                }
            }

            // ==========================================
            // UI LAYOUT
            // ==========================================
            Column {
                anchors.fill: parent
                anchors.margins: 25
                spacing: 25

                // CLOCK & DATE
                Column {
                    width: parent.width
                    spacing: 5
                    
                    Text {
                        id: timeDisplay
                        text: Qt.formatDateTime(new Date(), "hh:mm AP")
                        color: Colors.fg
                        font.pixelSize: 42
                        font.bold: true
                        font.family: "JetBrainsMono Nerd Font"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        id: dateDisplay
                        text: Qt.formatDateTime(new Date(), "dddd, MMMM d")
                        color: Colors.blue
                        font.pixelSize: 18
                        font.family: "JetBrainsMono Nerd Font"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Timer {
                        interval: 1000
                        running: true
                        repeat: true
                        onTriggered: {
                            var now = new Date()
                            timeDisplay.text = Qt.formatDateTime(now, "hh:mm AP")
                            dateDisplay.text = Qt.formatDateTime(now, "dddd, MMMM d")
                        }
                    }
                }

                Rectangle { 
                    width: parent.width
                    height: 1
                    color: Colors.bg2 
                }

                // CALENDAR 
                Item {
                    width: parent.width
                    implicitHeight: calColumn.implicitHeight
                    
                    Column {
                        id: calColumn
                        width: parent.width
                        spacing: 20

                        Text {
                            text: Qt.formatDateTime(new Date(), "MMMM yyyy")
                            color: Colors.yellow
                            font.pixelSize: 16
                            font.bold: true
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 16
                            Repeater {
                                model:["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
                                Text {
                                    text: modelData
                                    width: 30
                                    horizontalAlignment: Text.AlignHCenter
                                    color: Colors.orange
                                    font.pixelSize: 14
                                    font.bold: true
                                }
                            }
                        }

                        Grid {
                            columns: 7
                            spacing: 16
                            anchors.horizontalCenter: parent.horizontalCenter
                            
                            Repeater {
                                model: calendarModel
                                Rectangle {
                                    width: 30
                                    height: 30
                                    radius: 15
                                    color: model.isToday ? Colors.yellow : "transparent"
                                    Text {
                                        anchors.centerIn: parent
                                        text: model.dayText
                                        color: model.isToday ? Colors.bg0 : (model.isCurrentMonth ? Colors.fg : Colors.bg3)
                                        font.bold: model.isToday
                                        font.pixelSize: 13
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle { 
                    width: parent.width
                    height: 1
                    color: Colors.bg2 
                }

                // MEDIA PLAYER
                Rectangle {
                    width: parent.width
                    height: 140
                    radius: 12
                    color: Colors.bg1
                    border.color: Colors.bg2
                    border.width: 1
                    clip: true
                    
                    Image {
                        id: artImage
                        anchors.fill: parent
                        source: {
                            if (!leftBg.mediaArt || leftBg.mediaArt === "") {
                                return ""
                            }
                            if (leftBg.mediaArt.indexOf("file://") === 0) {
                                return leftBg.mediaArt
                            }
                            if (leftBg.mediaArt.indexOf("http://") === 0 || leftBg.mediaArt.indexOf("https://") === 0) {
                                return leftBg.mediaArt
                            }
                            return "file://" + leftBg.mediaArt
                        }
                        fillMode: Image.PreserveAspectCrop
                        visible: false
                        layer.enabled: true
                    }
                    
                    Rectangle {
                        id: maskRect
                        anchors.fill: parent
                        radius: 11
                        color: "black"
                        visible: false
                        layer.enabled: true
                    }
                    
                    MultiEffect {
                        anchors.fill: maskRect
                        source: artImage
                        maskEnabled: true
                        maskSource: maskRect
                        opacity: leftBg.mediaArt !== "" ? 0.8 : 0
                        blurEnabled: true
                        blurMax: 64
                        blur: 1.0
                        Behavior on opacity { 
                            NumberAnimation { 
                                duration: 300 
                            } 
                        }
                    }
                    
                    Rectangle {
                        anchors.fill: parent
                        radius: 11
                        color: leftBg.mediaArt !== "" ? "#B3000000" : "transparent"
                        Behavior on color { 
                            ColorAnimation { 
                                duration: 300 
                            } 
                        }
                    }
                    
                    Item {
                        anchors.fill: parent
                        anchors.margins: 15
                        
                        // Top Half: Info & Buttons
                        Item {
                            width: parent.width
                            height: 50
                            anchors.top: parent.top

                            Column {
                                width: parent.width - 120
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 4
                                Text { 
                                    text: leftBg.mediaTitle
                                    color: Colors.fg
                                    font.pixelSize: 16
                                    font.bold: true
                                    elide: Text.ElideRight
                                    maximumLineCount: 1
                                    width: parent.width 
                                }
                                Text { 
                                    text: leftBg.mediaArtist
                                    color: Colors.grey1
                                    font.pixelSize: 12
                                    elide: Text.ElideRight
                                    maximumLineCount: 1
                                    width: parent.width 
                                }
                            }
                            
                            Row {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 12
                                
                                Text { 
                                    text: "󰒮"
                                    color: Colors.fg
                                    font.pixelSize: 18
                                    font.family: "JetBrainsMono Nerd Font"
                                    anchors.verticalCenter: parent.verticalCenter
                                    MouseArea { 
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            Quickshell.execDetached(["playerctl", "previous"])
                                        }
                                    } 
                                }
                                Rectangle {
                                    width: 36
                                    height: 36
                                    radius: 18
                                    color: Colors.aqua
                                    anchors.verticalCenter: parent.verticalCenter
                                    Text { 
                                        anchors.centerIn: parent
                                        text: leftBg.mediaStatus === "Playing" ? "󰏤" : "󰐊"
                                        color: Colors.bg0
                                        font.pixelSize: 18
                                        font.family: "JetBrainsMono Nerd Font"
                                    }
                                    MouseArea { 
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            Quickshell.execDetached(["playerctl", "play-pause"])
                                        }
                                    }
                                }
                                Text { 
                                    text: "󰒭"
                                    color: Colors.fg
                                    font.pixelSize: 18
                                    font.family: "JetBrainsMono Nerd Font"
                                    anchors.verticalCenter: parent.verticalCenter
                                    MouseArea { 
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            Quickshell.execDetached(["playerctl", "next"])
                                        }
                                    } 
                                }
                            }
                        }

                        // Bottom Half: Timeline
                        Item {
                            width: parent.width
                            height: 35
                            anchors.bottom: parent.bottom

                            Text { 
                                text: leftRoot.formatTime(leftBg.mediaPosition)
                                color: Colors.grey1
                                font.pixelSize: 11
                                anchors.left: parent.left
                                anchors.top: parent.top 
                            }
                            Text { 
                                text: leftRoot.formatTime(leftBg.mediaLength)
                                color: Colors.grey1
                                font.pixelSize: 11
                                anchors.right: parent.right
                                anchors.top: parent.top 
                            }
                            
                            // EXACT SLIDER LOGIC FROM SNIPPET
                            Slider {
                                id: mediaProgress
                                anchors.bottom: parent.bottom
                                width: parent.width
                                height: 16
                                focusPolicy: Qt.NoFocus 
                                from: 0
                                to: leftBg.mediaLength > 0 ? leftBg.mediaLength : 1
                                value: leftBg.mediaPosition
                                
                                onPressedChanged: {
                                    if (!pressed) { 
                                        Quickshell.execDetached([
                                            "playerctl", 
                                            "position", 
                                            value.toString()
                                        ])
                                        leftBg.mediaPosition = value
                                    }
                                }
                                
                                background: Rectangle { 
                                    x: mediaProgress.leftPadding
                                    y: mediaProgress.topPadding + mediaProgress.availableHeight / 2 - height / 2
                                    width: mediaProgress.availableWidth
                                    height: 6
                                    radius: 3
                                    color: Colors.bg2
                                    Rectangle { 
                                        width: mediaProgress.visualPosition * parent.width
                                        height: parent.height
                                        color: Colors.aqua
                                        radius: 3 
                                    } 
                                }
                                handle: Rectangle { 
                                    x: mediaProgress.leftPadding + mediaProgress.visualPosition * (mediaProgress.availableWidth - width)
                                    y: mediaProgress.topPadding + mediaProgress.availableHeight / 2 - height / 2
                                    width: 14
                                    height: 14
                                    radius: 7
                                    color: Colors.bg0
                                    border.color: Colors.aqua
                                    border.width: mediaProgress.pressed ? 4 : 2
                                    scale: mediaProgress.hovered ? 1.2 : 1.0
                                    Behavior on border.width { 
                                        NumberAnimation { 
                                            duration: 150 
                                        } 
                                    }
                                    Behavior on scale { 
                                        NumberAnimation { 
                                            duration: 150
                                            easing.type: Easing.OutBack 
                                        } 
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle { 
                    width: parent.width
                    height: 1
                    color: Colors.bg2 
                }

                // VOLUME
                Column {
                    width: parent.width
                    spacing: 12
                    
                    Item {
                        width: parent.width
                        height: 20
                        
                        Row {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8
                            Text { 
                                text: "󰕾"
                                color: Colors.aqua
                                font.pixelSize: 18
                                font.family: "JetBrainsMono Nerd Font"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text { 
                                text: "Volume"
                                color: Colors.aqua
                                font.pixelSize: 14
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        
                        Text { 
                            anchors.right: parent.right
                            text: leftBg.volPercent + "%"
                            color: Colors.aqua
                            font.pixelSize: 14
                            font.family: "JetBrainsMono Nerd Font"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    
                    Slider {
                        id: volSlider
                        width: parent.width
                        height: 20
                        from: 0
                        to: 100
                        value: leftBg.volPercent

                        onMoved: { 
                            if (leftBg.audio) {
                                leftBg.audio.volume = value / 100.0
                            }
                        }

                        onPressedChanged: { 
                            if (!pressed) {
                                Quickshell.execDetached([
                                    "wpctl", 
                                    "set-volume", 
                                    "@DEFAULT_AUDIO_SINK@", 
                                    (value / 100.0).toFixed(2)
                                ])
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.NoButton
                            onWheel: (wheel) => {
                                let newVol = leftBg.volPercent + (wheel.angleDelta.y > 0 ? 5 : -5)
                                newVol = Math.max(0, Math.min(100, newVol))
                                if (leftBg.audio) {
                                    leftBg.audio.volume = newVol / 100.0
                                }
                                Quickshell.execDetached([
                                    "wpctl", 
                                    "set-volume", 
                                    "@DEFAULT_AUDIO_SINK@", 
                                    (newVol / 100.0).toFixed(2)
                                ])
                            }
                        }
                        background: Rectangle { 
                            x: volSlider.leftPadding
                            y: volSlider.topPadding + volSlider.availableHeight / 2 - height / 2
                            width: volSlider.availableWidth
                            height: 6
                            radius: 3
                            color: Colors.bg2
                            Rectangle { 
                                width: volSlider.visualPosition * parent.width
                                height: parent.height
                                color: Colors.aqua
                                radius: 3 
                            } 
                        }
                        handle: Rectangle { 
                            x: volSlider.leftPadding + volSlider.visualPosition * (volSlider.availableWidth - width)
                            y: volSlider.topPadding + volSlider.availableHeight / 2 - height / 2
                            width: 16
                            height: 16
                            radius: 8
                            color: Colors.bg0
                            border.color: Colors.aqua
                            border.width: volSlider.pressed ? 6 : 4
                        }
                    }
                }

                // BRIGHTNESS
                Column {
                    width: parent.width
                    spacing: 12
                    
                    Item {
                        width: parent.width
                        height: 20
                        
                        Row {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8
                            Text { 
                                text: "󰃠"
                                color: Colors.orange
                                font.pixelSize: 18
                                font.family: "JetBrainsMono Nerd Font"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text { 
                                text: "Brightness"
                                color: Colors.orange
                                font.pixelSize: 14
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        
                        Text { 
                            anchors.right: parent.right
                            text: leftBg.briPercent + "%"
                            color: Colors.orange
                            font.pixelSize: 14
                            font.family: "JetBrainsMono Nerd Font"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    
                    Slider {
                        id: briSlider
                        width: parent.width
                        height: 20
                        from: 0
                        to: 100
                        value: leftBg.briPercent

                        onMoved: { 
                            leftBg.briPercent = Math.round(value)
                        }

                        onPressedChanged: { 
                            if (!pressed) {
                                Quickshell.execDetached([
                                    "brightnessctl", 
                                    "set", 
                                    Math.round(value) + "%"
                                ])
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.NoButton
                            onWheel: (wheel) => {
                                let newBri = leftBg.briPercent + (wheel.angleDelta.y > 0 ? 5 : -5)
                                newBri = Math.max(0, Math.min(100, newBri))
                                leftBg.briPercent = newBri
                                Quickshell.execDetached([
                                    "brightnessctl", 
                                    "set", 
                                    newBri + "%"
                                ])
                            }
                        }
                        background: Rectangle { 
                            x: briSlider.leftPadding
                            y: briSlider.topPadding + briSlider.availableHeight / 2 - height / 2
                            width: briSlider.availableWidth
                            height: 6
                            radius: 3
                            color: Colors.bg2
                            Rectangle { 
                                width: briSlider.visualPosition * parent.width
                                height: parent.height
                                color: Colors.orange
                                radius: 3 
                            } 
                        }
                        handle: Rectangle { 
                            x: briSlider.leftPadding + briSlider.visualPosition * (briSlider.availableWidth - width)
                            y: briSlider.topPadding + briSlider.availableHeight / 2 - height / 2
                            width: 16
                            height: 16
                            radius: 8
                            color: Colors.bg0
                            border.color: Colors.orange
                            border.width: briSlider.pressed ? 6 : 4
                        }
                    }
                }
            }
        }
    }
}
