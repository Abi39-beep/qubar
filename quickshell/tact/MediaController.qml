pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Services.Mpris
import Qt5Compat.GraphicalEffects

Item {
    id: mediaCtrl
    signal closeRequested

    focus: true
    Keys.onEscapePressed: mediaCtrl.closeRequested()

    MouseArea {
        anchors.fill: parent
        z: -1
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: mediaCtrl.closeRequested()
    }

    property var activePlayer: null
    readonly property bool hasPlayer: mediaCtrl.activePlayer !== null
    readonly property bool isPlaying: mediaCtrl.hasPlayer && mediaCtrl.activePlayer.playbackState === MprisPlaybackState.Playing
    readonly property string title: mediaCtrl.hasPlayer && mediaCtrl.activePlayer.metadata && mediaCtrl.activePlayer.metadata["xesam:title"] ? mediaCtrl.activePlayer.metadata["xesam:title"] : "No Media"

    readonly property string artist: {
        if (mediaCtrl.hasPlayer && mediaCtrl.activePlayer.metadata && mediaCtrl.activePlayer.metadata["xesam:artist"]) {
            let a = mediaCtrl.activePlayer.metadata["xesam:artist"];
            return Array.isArray(a) ? a.join(", ") : String(a);
        }
        return "Unknown Artist";
    }

    readonly property string artUrl: mediaCtrl.hasPlayer && mediaCtrl.activePlayer.metadata && mediaCtrl.activePlayer.metadata["mpris:artUrl"] ? mediaCtrl.activePlayer.metadata["mpris:artUrl"] : ""
    readonly property real lengthSec: mediaCtrl.hasPlayer && mediaCtrl.activePlayer.metadata && mediaCtrl.activePlayer.metadata["mpris:length"] ? mediaCtrl.activePlayer.metadata["mpris:length"] / 1000000 : 0
    property real positionSec: 0

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: {
            let players = Mpris.players.values;
            let best = null;

            for (let i = 0; i < players.length; i++) {
                if (players[i] && players[i].playbackState === MprisPlaybackState.Playing) {
                    best = players[i];
                    break;
                }
                if (players[i] && !best)
                    best = players[i];
            }
            mediaCtrl.activePlayer = best;

            if (mediaCtrl.hasPlayer && typeof mediaCtrl.activePlayer.position !== "undefined") {
                mediaCtrl.positionSec = mediaCtrl.activePlayer.position;
            }
        }
    }

    function formatTime(totalSeconds) {
        if (totalSeconds <= 0 || isNaN(totalSeconds))
            return "0:00";
        let mins = Math.floor(totalSeconds / 60);
        let secs = Math.floor(totalSeconds % 60);
        return mins + ":" + (secs < 10 ? "0" : "") + secs;
    }

    // UI LAYOUT

    property Item maskItem: imageMask

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
        source: mediaCtrl.artUrl
        fillMode: Image.PreserveAspectCrop
        visible: mediaCtrl.artUrl !== ""
        opacity: Config.mediaCtrlArtOpacity

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: mediaCtrl.maskItem
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Colors.bg1
        opacity: mediaCtrl.artUrl !== "" ? Config.mediaCtrlTintOpacity : 0.0
        radius: Config.mediaCtrlRadius
    }

    Item {
        anchors.fill: parent
        anchors.margins: 18

        Item {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 50

            Column {
                anchors.left: parent.left
                width: parent.width - 130
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                Text {
                    text: mediaCtrl.title
                    font.bold: true
                    color: Colors.fg0
                    font.family: Config.fontName
                    font.pixelSize: 18
                    elide: Text.ElideRight
                    width: parent.width
                }

                Text {
                    text: mediaCtrl.artist
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

                // PREVIOUS BUTTON
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

                        onClicked: {
                            if (mediaCtrl.hasPlayer)
                                mediaCtrl.activePlayer.previous();
                        }
                    }
                }

                // PLAY/PAUSE BUTTON
                Rectangle {
                    width: 44
                    height: 44
                    radius: 22
                    color: playArea.containsMouse ? Colors.blue : Colors.aqua
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: mediaCtrl.isPlaying ? "󰏤" : "󰐊"
                        font.family: Config.fontName
                        color: Colors.bg0
                        font.pixelSize: 24
                        anchors.centerIn: parent
                        anchors.horizontalCenterOffset: mediaCtrl.isPlaying ? 0 : 2
                    }

                    MouseArea {
                        id: playArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (mediaCtrl.hasPlayer)
                                mediaCtrl.activePlayer.togglePlaying();
                        }
                    }
                }

                // NEXT BUTTON
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

                        onClicked: {
                            if (mediaCtrl.hasPlayer)
                                mediaCtrl.activePlayer.next();
                        }
                    }
                }
            }
        }

        // --- BOTTOM SECTION (Progress Bar) ---
        Row {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 12

            Text {
                text: mediaCtrl.formatTime(mediaCtrl.positionSec)
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
                    width: mediaCtrl.lengthSec > 0 ? Math.min((mediaCtrl.positionSec / mediaCtrl.lengthSec), 1.0) * parent.width : 0
                    height: 4
                    radius: 2
                    color: Colors.aqua
                }

                Rectangle {
                    x: mediaCtrl.lengthSec > 0 ? Math.max(0, Math.min((mediaCtrl.positionSec / mediaCtrl.lengthSec) * parent.width, parent.width) - width / 2) : 0
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
                        if (mediaCtrl.lengthSec > 0 && mediaCtrl.hasPlayer) {
                            let percentage = mouse.x / width;
                            let seekTargetSec = percentage * mediaCtrl.lengthSec;
                            mediaCtrl.activePlayer.position = seekTargetSec;
                            mediaCtrl.positionSec = seekTargetSec;
                        }
                    }
                }
            }

            Text {
                text: mediaCtrl.formatTime(mediaCtrl.lengthSec)
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
