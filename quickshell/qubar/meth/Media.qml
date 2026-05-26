import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import ".."

Item {
    id: root
    width: 200
    height: 25

    property bool popupOpen: false
    readonly property list<MprisPlayer> players: Mpris.players.values

    readonly property MprisPlayer activePlayer: {
        for (let i = 0; i < players.length; i++) {
            if (players[i] && players[i].isPlaying)
                return players[i];
        }
        return players.length > 0 ? players[0] : null;
    }

    readonly property string titleText: activePlayer ? (activePlayer.trackTitle || "Unknown Title") : "No media playing"

    function clamp(v, min, max) {
        return Math.max(min, Math.min(max, v));
    }

    function progressValue() {
        if (!activePlayer || !activePlayer.length || activePlayer.length <= 0)
            return 0;
        return clamp(activePlayer.position / activePlayer.length, 0, 1);
    }

    Rectangle {
        anchors.fill: parent
        radius: 15
        color: Colors.bg1
        border.color: Colors.bg3
        border.width: 1

        Item {
            id: clipper
            x: 8
            y: 0
            width: parent.width - 16
            height: 25
            clip: true

            Text {
                id: scrollingText
                text: root.titleText
                color: Colors.fg
                font.pixelSize: 14
                y: 6
                x: 0
                width: implicitWidth
                elide: Text.ElideNone
                onTextChanged: x = 0
            }

            SequentialAnimation {
                running: scrollingText.implicitWidth > clipper.width
                loops: Animation.Infinite

                NumberAnimation {
                    target: scrollingText
                    property: "x"
                    from: 0
                    to: -(scrollingText.implicitWidth - clipper.width)
                    duration: 7000
                    easing.type: Easing.Linear
                }
                PauseAnimation {
                    duration: 1000
                }
                NumberAnimation {
                    target: scrollingText
                    property: "x"
                    from: -(scrollingText.implicitWidth - clipper.width)
                    to: 0
                    duration: 7000
                    easing.type: Easing.Linear
                }
                PauseAnimation {
                    duration: 1000
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.popupOpen = !root.popupOpen
        }
    }

    PopupWindow {
        visible: root.popupOpen
        parentWindow: root.Window ? root.Window : null
        width: 360
        height: 150
        relativeX: 0
        relativeY: root.height + 6

        Rectangle {
            anchors.fill: parent
            radius: 10
            color: Colors.bg0
            border.color: Colors.bg3
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                Text {
                    Layout.fillWidth: true
                    text: root.titleText
                    color: Colors.fg
                    elide: Text.ElideRight
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 6
                    radius: 3
                    color: Colors.bg3

                    Rectangle {
                        width: parent.width * root.progressValue()
                        height: parent.height
                        radius: 3
                        color: Colors.blue
                    }
                }

                RowLayout {
                    spacing: 8

                    Button {
                        text: "Prev"
                        enabled: root.activePlayer !== null
                        onClicked: if (root.activePlayer)
                            root.activePlayer.previous()
                    }

                    Button {
                        text: root.activePlayer && root.activePlayer.isPlaying ? "Pause" : "Play"
                        enabled: root.activePlayer !== null
                        onClicked: if (root.activePlayer)
                            root.activePlayer.togglePlaying()
                    }

                    Button {
                        text: "Next"
                        enabled: root.activePlayer !== null
                        onClicked: if (root.activePlayer)
                            root.activePlayer.next()
                    }
                }
            }
        }
    }

    FrameAnimation {
        running: root.activePlayer !== null && root.activePlayer.isPlaying
        onTriggered: {
            if (root.activePlayer)
                root.activePlayer.positionChanged();
        }
    }
}
