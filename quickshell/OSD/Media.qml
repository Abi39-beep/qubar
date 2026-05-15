import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "."

Rectangle {
    id: mediaRoot
    width: parent ? parent.width : 420
    height: 130
    radius: 12
    color: Colors.bg1
    border.color: Colors.bg2
    border.width: 1
    clip: true

    property string mediaStatus: "Stopped"
    property string mediaTitle: "No Media"
    property string mediaArtist: "Unknown Artist"
    property string mediaArt: ""
    property string mediaPlayerName: ""
    property real mediaLength: 0
    property real mediaPosition: 0

    function formatTime(seconds) {
        if (isNaN(seconds) || seconds <= 0) {
            return "0:00"
        }
        let m = Math.floor(seconds / 60)
        let s = Math.floor(seconds % 60)
        return m + ":" + (s < 10 ? "0" : "") + s
    }

    // ==========================================
    // BACKEND POLLING (Robust, No-Stutter Logic)
    // ==========================================
    Timer { 
        id: mediaPollTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: { 
            mediaWatcher.running = true
            if (mediaRoot.mediaStatus === "Playing") {
                mediaPosWatcher.running = true
            }
        } 
    }

    Process {
        id: mediaWatcher
        command: [
            "playerctl", 
            "metadata", 
            "--format", 
            "{{status}}||{{title}}||{{artist}}||{{mpris:artUrl}}||{{mpris:length}}||{{playerName}}"
        ]
        stdout: SplitParser {
            onRead: data => {
                let parts = data.split("||")
                if (parts.length >= 6) {
                    mediaRoot.mediaStatus = parts[0].trim()
                    mediaRoot.mediaTitle = parts[1].trim() || "Unknown Title"
                    mediaRoot.mediaArtist = parts[2].trim() || "Unknown Artist"
                    
                    let newArt = parts[3] ? parts[3].trim() : ""
                    if (mediaRoot.mediaArt !== newArt) {
                        mediaRoot.mediaArt = newArt
                    }
                    
                    let len = parseInt(parts[4].trim())
                    mediaRoot.mediaLength = isNaN(len) ? 0 : (len / 1000000.0)
                    
                    mediaRoot.mediaPlayerName = parts[5].trim().toLowerCase()
                }
            }
        }
        onExited: (code) => {
            if (code !== 0) {
                mediaRoot.mediaStatus = "Stopped"
                mediaRoot.mediaTitle = "No Media"
                mediaRoot.mediaArtist = ""
                mediaRoot.mediaArt = ""
                mediaRoot.mediaLength = 0
                mediaRoot.mediaPosition = 0
            }
        }
    }

    Process {
        id: mediaPosWatcher
        command: [
            "playerctl", 
            "position"
        ]
        stdout: SplitParser { 
            onRead: data => { 
                let pos = parseFloat(data.trim())
                // FIX: Explicitly update value ONLY when not being dragged. Prevents all stuttering!
                if (!isNaN(pos) && !mediaProgress.pressed && !wheelArea.containsMouse) {
                    mediaRoot.mediaPosition = pos
                    mediaProgress.value = pos
                }
            } 
        }
    }

    // ==========================================
    // UI LAYOUT (Matched perfectly to your picture)
    // ==========================================
    Row {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 15

        // Left Side: Album Art Square
        Rectangle {
            width: 100
            height: 100
            radius: 10
            color: Colors.bg2
            clip: true
            
            Image {
                id: artImage
                anchors.fill: parent
                source: {
                    if (!mediaRoot.mediaArt || mediaRoot.mediaArt === "") return ""
                    if (mediaRoot.mediaArt.indexOf("http://") === 0 || mediaRoot.mediaArt.indexOf("https://") === 0) return mediaRoot.mediaArt
                    if (mediaRoot.mediaArt.indexOf("file://") === 0) return mediaRoot.mediaArt
                    return "file://" + mediaRoot.mediaArt
                }
                fillMode: Image.PreserveAspectCrop
            }
            
            // Fallback icon if no art
            Text {
                anchors.centerIn: parent
                text: "󰎆"
                font.pixelSize: 32
                font.family: "JetBrainsMono Nerd Font"
                color: Colors.grey1
                visible: artImage.status !== Image.Ready
            }
        }

        // Right Side: Content & Controls
        Item {
            width: parent.width - 115 // Remaining space
            height: 100

            // Top: Title, Artist, and Spotify Icon
            Item {
                width: parent.width
                height: 40
                anchors.top: parent.top

                Column {
                    anchors.left: parent.left
                    anchors.right: playerIcon.left
                    anchors.rightMargin: 10
                    spacing: 2
                    
                    Text { 
                        text: mediaRoot.mediaTitle
                        color: Colors.fg
                        font.pixelSize: 16
                        font.bold: true
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        width: parent.width 
                    }
                    Text { 
                        text: mediaRoot.mediaArtist
                        color: Colors.grey1
                        font.pixelSize: 13
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        width: parent.width 
                    }
                }

                // App Icon (Spotify logo if Spotify, generic otherwise)
                Text {
                    id: playerIcon
                    anchors.right: parent.right
                    anchors.top: parent.top
                    text: mediaRoot.mediaPlayerName.indexOf("spotify") !== -1 ? "" : "󰎆"
                    color: Colors.fg
                    font.pixelSize: 16
                    font.family: "JetBrainsMono Nerd Font"
                }
            }

            // Middle: Sleek Progress Bar
            Slider {
                id: mediaProgress
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 5 // Nudge down slightly
                width: parent.width
                height: 16
                focusPolicy: Qt.NoFocus 
                
                from: 0
                to: mediaRoot.mediaLength > 0 ? mediaRoot.mediaLength : 1
                
                // Immediately visual update while dragging
                onMoved: {
                    mediaRoot.mediaPosition = value
                }

                // Send command instantly when mouse lets go or clicks the bar
                onPressedChanged: { 
                    if (!pressed) {
                        Quickshell.execDetached([
                            "playerctl", 
                            "position", 
                            value.toString()
                        ])
                    }
                }

                MouseArea {
                    id: wheelArea
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    hoverEnabled: true
                    
                    onWheel: (wheel) => {
                        let newPos = mediaRoot.mediaPosition + (wheel.angleDelta.y > 0 ? 5 : -5)
                        newPos = Math.max(0, Math.min(mediaRoot.mediaLength, newPos))
                        mediaRoot.mediaPosition = newPos
                        mediaProgress.value = newPos
                        Quickshell.execDetached([
                            "playerctl", 
                            "position", 
                            newPos.toString()
                        ])
                    }
                }
                
                background: Rectangle { 
                    x: mediaProgress.leftPadding
                    y: mediaProgress.topPadding + mediaProgress.availableHeight / 2 - height / 2
                    width: mediaProgress.availableWidth
                    height: 8
                    radius: 4
                    color: Colors.bg2 // Dark grey track
                    
                    Rectangle { 
                        width: mediaProgress.visualPosition * parent.width
                        height: parent.height
                        color: Colors.fg // White filled track
                        radius: 4 
                    } 
                }
                
                // Hidden handle to match your clean, pill-bar aesthetic
                handle: Item {}
            }

            // Bottom: Timestamps & Controls
            Item {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 28

                Text { 
                    text: mediaRoot.formatTime(mediaRoot.mediaPosition)
                    color: Colors.fg
                    font.pixelSize: 12
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                Row {
                    anchors.centerIn: parent
                    spacing: 8
                    
                    Rectangle {
                        width: 28
                        height: 28
                        radius: 6
                        color: Colors.bg2
                        Text { 
                            anchors.centerIn: parent
                            text: "󰒮"
                            color: Colors.fg
                            font.pixelSize: 14
                            font.family: "JetBrainsMono Nerd Font"
                        }
                        MouseArea { 
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                Quickshell.execDetached(["playerctl", "previous"])
                                mediaWatcher.running = true
                            }
                        } 
                    }
                    Rectangle {
                        width: 28
                        height: 28
                        radius: 6
                        color: Colors.bg2
                        Text { 
                            anchors.centerIn: parent
                            text: mediaRoot.mediaStatus === "Playing" ? "󰏤" : "󰐊"
                            color: Colors.fg
                            font.pixelSize: 14
                            font.family: "JetBrainsMono Nerd Font"
                        }
                        MouseArea { 
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                Quickshell.execDetached(["playerctl", "play-pause"])
                                mediaWatcher.running = true
                            }
                        }
                    }
                    Rectangle {
                        width: 28
                        height: 28
                        radius: 6
                        color: Colors.bg2
                        Text { 
                            anchors.centerIn: parent
                            text: "󰒭"
                            color: Colors.fg
                            font.pixelSize: 14
                            font.family: "JetBrainsMono Nerd Font"
                        }
                        MouseArea { 
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                Quickshell.execDetached(["playerctl", "next"])
                                mediaWatcher.running = true
                            }
                        } 
                    }
                }

                Text { 
                    text: mediaRoot.formatTime(mediaRoot.mediaLength)
                    color: Colors.fg
                    font.pixelSize: 12
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}
