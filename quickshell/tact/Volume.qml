import QtQuick
import Quickshell
import Quickshell.Io

Column {
    id: root
    spacing: 12

    property int brightnessVal: 50
    property int volumeVal: 50
    property bool volumeMuted: false

    // THE FIX: Increased to 300ms to guarantee the layout is completely finished drawing!
    property bool isReady: false
    onVisibleChanged: {
        if (visible) {
            isReady = false;
            readyTimer.restart();

            brightProc.running = false;
            brightProc.running = true;
            volProc.running = false;
            volProc.running = true;
        } else {
            isReady = false;
            readyTimer.stop();
        }
    }
    Timer {
        id: readyTimer
        interval: 300
        onTriggered: root.isReady = true
    }

    // ==========================================
    // 1. BRIGHTNESS BACKEND
    // ==========================================
    Process {
        id: brightProc
        command: ["bash", "-c", "brightnessctl -m | cut -d, -f4 | tr -d %"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                if (!brightMouseArea.pressed) {
                    root.brightnessVal = parseInt(data.trim()) || 0;
                }
            }
        }
    }
    Timer {
        interval: 150
        running: true
        repeat: true
        onTriggered: brightProc.running = true
    }

    Process {
        id: setBrightProc
        running: false
    }
    function setBrightness(val) {
        root.brightnessVal = val;
        setBrightProc.command = ["bash", "-c", "brightnessctl s " + val + "%"];
        setBrightProc.running = true;
    }

    // ==========================================
    // 2. VOLUME BACKEND
    // ==========================================
    Process {
        id: volProc
        command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                let text = data.trim();
                if (!volMouseArea.pressed) {
                    root.volumeMuted = text.includes("MUTED");
                    let match = text.match(/[\d\.]+/);
                    if (match) {
                        root.volumeVal = Math.round(parseFloat(match[0]) * 100);
                    }
                }
            }
        }
    }
    Timer {
        interval: 150
        running: true
        repeat: true
        onTriggered: volProc.running = true
    }

    Process {
        id: setVolProc
        running: false
    }
    function setVolume(val) {
        root.volumeVal = val;
        setVolProc.command = ["bash", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ " + (val / 100).toFixed(2)];
        setVolProc.running = true;
    }

    function getVolIcon(vol, muted) {
        if (muted || vol === 0)
            return "󰝟";
        if (vol > 50)
            return "󰕾";
        if (vol > 25)
            return "󰖀";
        return "󰕿";
    }

    function getBriIcon(val) {
        if (val > 66)
            return "󰃠";
        if (val > 33)
            return "󰃟";
        return "󰃞";
    }

    // ==========================================
    // 3. BRIGHTNESS SLIDER UI
    // ==========================================
    Rectangle {
        width: parent.width
        height: Config.ccSliderHeight
        radius: height / 2
        color: Colors.bg1
        border.color: Colors.bg2
        border.width: 1

        property real fillWidth: parent.width * (root.brightnessVal / 100)

        Rectangle {
            width: Math.max(parent.height, parent.fillWidth)
            height: parent.height
            radius: height / 2

            color: root.brightnessVal === 0 ? Colors.bg2 : Colors.aqua

            // THE FIX: "duration: 0" forces an instant mathematical snap with zero visual tearing!
            Behavior on width {
                NumberAnimation {
                    duration: root.isReady ? 150 : 0
                    easing.type: Easing.OutQuad
                }
            }
            Behavior on color {
                ColorAnimation {
                    duration: root.isReady ? 150 : 0
                }
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: (parent.height - paintedWidth) / 2
            text: root.getBriIcon(root.brightnessVal)
            font.family: Config.fontName
            font.pixelSize: Config.fontSizeCcSliderIcon
            color: Colors.bg0
        }

        MouseArea {
            id: brightMouseArea
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor

            onPositionChanged: mouse => {
                if (pressed)
                    updateVal(mouse.x);
            }
            onPressed: mouse => {
                updateVal(mouse.x);
            }
            onWheel: wheel => {
                let step = wheel.angleDelta.y > 0 ? 5 : -5;
                root.setBrightness(Math.max(0, Math.min(100, root.brightnessVal + step)));
            }
            function updateVal(xPos) {
                let perc = Math.max(0, Math.min(1, xPos / width));
                root.setBrightness(Math.round(perc * 100));
            }
        }
    }

    // ==========================================
    // 4. VOLUME SLIDER UI
    // ==========================================
    Rectangle {
        width: parent.width
        height: Config.ccSliderHeight
        radius: height / 2
        color: Colors.bg1
        border.color: Colors.bg2
        border.width: 1

        property real fillWidth: parent.width * (root.volumeVal / 100)

        Rectangle {
            width: Math.max(parent.height, parent.fillWidth)
            height: parent.height
            radius: height / 2

            color: root.volumeMuted || root.volumeVal === 0 ? Colors.bg2 : Colors.aqua

            // THE FIX: "duration: 0" forces an instant mathematical snap with zero visual tearing!
            Behavior on width {
                NumberAnimation {
                    duration: root.isReady ? 150 : 0
                    easing.type: Easing.OutQuad
                }
            }
            Behavior on color {
                ColorAnimation {
                    duration: root.isReady ? 150 : 0
                }
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: (parent.height - paintedWidth) / 2
            text: root.getVolIcon(root.volumeVal, root.volumeMuted)
            font.family: Config.fontName
            font.pixelSize: Config.fontSizeCcSliderIcon
            color: Colors.bg0
        }

        MouseArea {
            id: volMouseArea
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor

            onPositionChanged: mouse => {
                if (pressed)
                    updateVal(mouse.x);
            }
            onPressed: mouse => {
                updateVal(mouse.x);
            }
            onWheel: wheel => {
                let step = wheel.angleDelta.y > 0 ? 5 : -5;
                root.setVolume(Math.max(0, Math.min(100, root.volumeVal + step)));
            }
            function updateVal(xPos) {
                let perc = Math.max(0, Math.min(1, xPos / width));
                root.setVolume(Math.round(perc * 100));
            }
        }
    }
}
