import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Io
import Qt5Compat.GraphicalEffects

Item {
    id: mediaCtrl

    signal closeRequested

    // --- THE ESC KEY FIX ---
    focus: true
    Keys.onEscapePressed: closeRequested()

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: closeRequested()
    }

    // --- MPRIS NATIVE BINDINGS ---
    property var activePlayer: null
    readonly property bool hasPlayer: activePlayer !== null
    readonly property bool isPlaying: hasPlayer && activePlayer.playbackState === 1

    readonly property string title: hasPlayer && activePlayer.metadata && activePlayer.metadata["xesam:title"] ? activePlayer.metadata["xesam:title"] : "No Media"
    readonly property string artist: {
        if (hasPlayer && activePlayer.metadata && activePlayer.metadata["xesam:artist"]) {
            let a = activePlayer.metadata["xesam:artist"];
            return Array.isArray(a) ? a.join(", ") : String(a);
        }
        return "Unknown Artist";
    }
    readonly property string artUrl: hasPlayer && activePlayer.metadata && activePlayer.metadata["mpris:artUrl"] ? activePlayer.metadata["mpris:artUrl"] : ""

    property real lengthSec: 0
    property real positionSec: 0

    function formatTime(totalSeconds) {
        if (totalSeconds <= 0 || isNaN(totalSeconds))
            return "0:00";
        let mins = Math.floor(totalSeconds / 60);
        let secs = Math.floor(totalSeconds % 60);
        return mins + ":" + (secs < 10 ? "0" : "") + secs;
    }

    Process {
        id: syncTime
        command: ["bash", "-c", "echo $(playerctl metadata --format '{{mpris:length}}' 2>/dev/null) $(playerctl position 2>/dev/null)"]
        stdout: SplitParser {
            onRead: data => {
                let parts = data.trim().split(" ");
                if (parts.length >= 2) {
                    let rawLen = parseFloat(parts[0]);
                    let rawPos = parseFloat(parts[1]);
                    if (!isNaN(rawLen))
                        mediaCtrl.lengthSec = rawLen / 1000000;
                    if (!isNaN(rawPos))
                        mediaCtrl.positionSec = rawPos;
                }
            }
        }
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: {
            let players = Mpris.players.values;
            let best = null;
            for (let i = 0; i < players.length; i++) {
                if (players[i] && players[i].playbackState === 1) {
                    best = players[i];
                    break;
                }
                if (players[i] && !best)
                    best = players[i];
            }
            mediaCtrl.activePlayer = best;

            if (mediaCtrl.isPlaying)
                syncTime.running = true;
        }
    }

    // --- Rounded Album Art (Linked to Config) ---
    Rectangle {
        id: imageMask
        anchors.fill: parent
        radius: Config.mediaCtrlRadius
        color: "black"
        visible: false
    }

    Image {
        id: albumArt
        anchors.fill: parent
        source: artUrl
        fillMode: Image.PreserveAspectCrop
        visible: artUrl !== ""
        opacity: Config.mediaCtrlArtOpacity

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: imageMask
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Colors.bg1
        opacity: artUrl !== "" ? Config.mediaCtrlTintOpacity : 0.0
        radius: Config.mediaCtrlRadius
    }

    Item {
        anchors.fill: parent
        anchors.margins: 18

        // --- TOP SECTION (Info & Buttons) ---
        Row {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 50

            Column {
                width: parent.width - 130
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4
                Text {
                    text: title
                    font.bold: true
                    color: Colors.fg0
                    font.family: Config.fontName
                    font.pixelSize: 18
                    elide: Text.ElideRight
                    width: parent.width
                }
                Text {
                    text: artist
                    color: Colors.fg2
                    font.family: Config.fontName
                    font.pixelSize: 13
                    elide: Text.ElideRight
                    width: parent.width
                }
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                Text {
                    text: "󰒮"
                    font.family: Config.fontName
                    font.pixelSize: 22
                    color: prevArea.containsMouse ? Colors.aqua : Colors.fg0
                    anchors.verticalCenter: parent.verticalCenter
                    MouseArea {
                        id: prevArea
                        anchors.fill: parent
                        anchors.margins: -10
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Quickshell.execDetached(["playerctl", "previous"])
                    }
                }

                Rectangle {
                    width: 44
                    height: 44
                    radius: 22
                    color: playArea.containsMouse ? Colors.blue : Colors.aqua
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        text: isPlaying ? "󰏤" : "󰐊"
                        font.family: Config.fontName
                        color: Colors.bg0
                        font.pixelSize: 24
                        anchors.centerIn: parent
                        anchors.horizontalCenterOffset: isPlaying ? 0 : 2
                    }
                    MouseArea {
                        id: playArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Quickshell.execDetached(["playerctl", "play-pause"])
                    }
                }

                Text {
                    text: "󰒭"
                    font.family: Config.fontName
                    font.pixelSize: 22
                    color: nextArea.containsMouse ? Colors.aqua : Colors.fg0
                    anchors.verticalCenter: parent.verticalCenter
                    MouseArea {
                        id: nextArea
                        anchors.fill: parent
                        anchors.margins: -10
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Quickshell.execDetached(["playerctl", "next"])
                    }
                }
            }
        }

        // --- BOTTOM SECTION (Straight Progress Bar) ---
        Row {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 12

            Text {
                text: formatTime(positionSec)
                color: Colors.fg2
                font.family: Config.fontName
                font.pixelSize: 11
                width: 32
                anchors.verticalCenter: parent.verticalCenter
            }

            Item {
                width: parent.width - 88
                height: 20
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: 4
                    radius: 2
                    color: Colors.bg3
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: lengthSec > 0 ? Math.min((positionSec / lengthSec), 1.0) * parent.width : 0
                    height: 4
                    radius: 2
                    color: Colors.aqua
                }

                Rectangle {
                    x: lengthSec > 0 ? Math.max(0, Math.min((positionSec / lengthSec) * parent.width, parent.width) - width / 2) : 0
                    anchors.verticalCenter: parent.verticalCenter
                    width: 14
                    height: 14
                    radius: 7
                    color: Colors.bg0
                    border.color: Colors.aqua
                    border.width: 2
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: mouse => {
                        if (lengthSec > 0) {
                            let percentage = mouse.x / width;
                            let seekTarget = percentage * lengthSec;
                            Quickshell.execDetached(["playerctl", "position", seekTarget.toString()]);
                            mediaCtrl.positionSec = seekTarget;
                        }
                    }
                }
            }

            Text {
                text: formatTime(lengthSec)
                color: Colors.fg2
                font.family: Config.fontName
                font.pixelSize: 11
                width: 32
                horizontalAlignment: Text.AlignRight
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
