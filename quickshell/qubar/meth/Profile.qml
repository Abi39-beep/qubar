import QtQuick
import Quickshell.Services.UPower
import ".."

Rectangle {
    id: root
    signal openMenu

    property bool isActive: PowerProfiles.profile !== PowerProfile.Balanced
    property bool isHovered: menuArea.containsMouse || circleArea.containsMouse

    width: parent.width
    height: 56
    radius: 28

    color: root.isActive ? (root.isHovered ? Qt.rgba(Colors.aqua.r, Colors.aqua.g, Colors.aqua.b, 0.85) : Colors.aqua) : (root.isHovered ? Colors.bg1 : Colors.bg0)
    border.color: Colors.bg3
    border.width: root.isActive ? 0 : 2

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }

    function getProfileIcon() {
        if (PowerProfiles.profile === PowerProfile.PowerSaver)
            return "󰌪";
        if (PowerProfiles.profile === PowerProfile.Performance)
            return "󰓅";
        return "󰾆";
    }

    function formatProfileName() {
        if (PowerProfiles.profile === PowerProfile.PowerSaver)
            return "Power Saver";
        if (PowerProfiles.profile === PowerProfile.Performance)
            return "Performance";
        return "Balanced";
    }

    Row {
        anchors.fill: parent
        anchors.margins: 6
        spacing: 12

        Rectangle {
            width: 44
            height: 44
            radius: 22

            color: root.isActive ? (circleArea.containsMouse ? Qt.rgba(0, 0, 0, 0.45) : Qt.rgba(0, 0, 0, 0.30)) : (circleArea.containsMouse ? Colors.bg3 : Colors.bg2)

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }

            Text {
                anchors.centerIn: parent
                text: root.getProfileIcon()
                font.family: "SF Pro Display"
                font.pixelSize: 18
                color: root.isActive ? Colors.bg0 : Colors.fg0
            }

            MouseArea {
                id: circleArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true

                onClicked: {
                    if (PowerProfiles.profile === PowerProfile.Balanced) {
                        if (PowerProfiles.hasPerformanceProfile) {
                            PowerProfiles.profile = PowerProfile.Performance;
                        } else {
                            PowerProfiles.profile = PowerProfile.PowerSaver;
                        }
                    } else if (PowerProfiles.profile === PowerProfile.Performance) {
                        PowerProfiles.profile = PowerProfile.PowerSaver;
                    } else {
                        PowerProfiles.profile = PowerProfile.Balanced;
                    }
                }
            }
        }

        Item {
            width: parent.width - 56
            height: parent.height

            Column {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 2

                Text {
                    text: "Profile"
                    font.family: "SF Pro Display"
                    font.pixelSize: 14
                    font.bold: true
                    color: root.isActive ? Colors.bg0 : Colors.fg0
                }

                Text {
                    text: root.formatProfileName()
                    font.family: "SF Pro Display"
                    font.pixelSize: 12
                    color: root.isActive ? Qt.rgba(Colors.bg0.r, Colors.bg0.g, Colors.bg0.b, 0.7) : Colors.fg3
                    width: parent.width
                    elide: Text.ElideRight
                }
            }

            MouseArea {
                id: menuArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: root.openMenu()
            }
        }
    }
}
