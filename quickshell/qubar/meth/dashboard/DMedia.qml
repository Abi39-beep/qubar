import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import "../.."

Item {
    width: parent.width
    height: 110
    Rectangle {
        id: mediaBaseRect
        anchors.fill: parent
        radius: 12
        color: Colors.bg1
        border.width: 1
        border.color: Colors.bg2
        Image {
            id: artImage
            anchors.fill: parent
            anchors.margins: 1
            fillMode: Image.PreserveAspectCrop
            visible: false
            source: {
                if (!dashWidget.mediaArt)
                    return "";
                if (dashWidget.mediaArt.startsWith("http") || dashWidget.mediaArt.startsWith("file://"))
                    return dashWidget.mediaArt;
                return "file://" + dashWidget.mediaArt;
            }
        }
        Rectangle {
            id: maskRect
            anchors.fill: parent
            anchors.margins: 1
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
            opacity: dashWidget.mediaArt !== "" ? 0.6 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 300
                }
            }
        }
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: 11
            color: dashWidget.mediaArt !== "" ? "#B3000000" : "transparent"
            Behavior on color {
                ColorAnimation {
                    duration: 300
                }
            }
        }

        Item {
            anchors.fill: parent
            anchors.margins: 12
            Item {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 40
                Column {
                    anchors.left: parent.left
                    anchors.right: btnRow.left
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4
                    Text {
                        text: dashWidget.mediaTitle
                        color: Colors.fg
                        font.pixelSize: 14
                        font.bold: true
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        width: parent.width
                    }
                    Text {
                        text: dashWidget.mediaArtist
                        color: Colors.grey1
                        font.pixelSize: 12
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        width: parent.width
                    }
                }
                Row {
                    id: btnRow
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8
                    Rectangle {
                        width: 30
                        height: 30
                        radius: 15
                        color: hoverPrev.containsMouse ? Colors.bg2 : "transparent"
                        Text {
                            anchors.centerIn: parent
                            text: "󰒮"
                            color: Colors.fg
                            font.pixelSize: 16
                            font.family: "JetBrainsMono Nerd Font"
                        }
                        MouseArea {
                            id: hoverPrev
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                Quickshell.execDetached(["playerctl", "previous"]);
                                mediaWatcher.running = true;
                            }
                        }
                    }
                    Rectangle {
                        width: 36
                        height: 36
                        radius: 18
                        color: Colors.blue
                        Text {
                            anchors.centerIn: parent
                            text: dashWidget.mediaStatus === "Playing" ? "󰏤" : "󰐊"
                            color: Colors.bg0
                            font.pixelSize: 18
                            font.family: "JetBrainsMono Nerd Font"
                            anchors.horizontalCenterOffset: dashWidget.mediaStatus === "Playing" ? 0 : 2
                        }
                        MouseArea {
                            id: hoverPlay
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                Quickshell.execDetached(["playerctl", "play-pause"]);
                                mediaWatcher.running = true;
                            }
                        }
                    }
                    Rectangle {
                        width: 30
                        height: 30
                        radius: 15
                        color: hoverNext.containsMouse ? Colors.bg2 : "transparent"
                        Text {
                            anchors.centerIn: parent
                            text: "󰒭"
                            color: Colors.fg
                            font.pixelSize: 16
                            font.family: "JetBrainsMono Nerd Font"
                        }
                        MouseArea {
                            id: hoverNext
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                Quickshell.execDetached(["playerctl", "next"]);
                                mediaWatcher.running = true;
                            }
                        }
                    }
                }
            }
            Item {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 35
                Text {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    text: dashWidget.formatTime(dashWidget.mediaPosition)
                    color: Colors.grey1
                    font.pixelSize: 11
                }
                Text {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    text: dashWidget.formatTime(dashWidget.mediaLength)
                    color: Colors.grey1
                    font.pixelSize: 11
                }
                Slider {
                    id: mediaProgress
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 20
                    focusPolicy: Qt.NoFocus
                    from: 0
                    to: dashWidget.mediaLength > 0 ? dashWidget.mediaLength : 1
                    value: dashWidget.mediaPosition
                    onPressedChanged: {
                        if (!pressed) {
                            Quickshell.execDetached(["playerctl", "position", value.toString()]);
                            dashWidget.mediaPosition = value;
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
                            color: Colors.blue
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
                        border.color: Colors.blue
                        border.width: mediaProgress.pressed ? 4 : 2
                    }
                }
            }
        }
    }
}
