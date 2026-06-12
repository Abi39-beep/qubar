import QtQuick
import Quickshell

Item {
    id: powerMenuRoot

    signal closeRequested

    Row {
        anchors.centerIn: parent
        spacing: 16

        Repeater {
            // Define the 5 buttons, their Nerd Font icons, hover colors, and system commands
            model: [
                {
                    name: "Lock",
                    icon: "󰌾",
                    color: Colors.green,
                    cmd: ["loginctl", "lock-session"]
                },
                {
                    name: "Sleep",
                    icon: "󰒲",
                    color: Colors.blue,
                    cmd: ["systemctl", "suspend"]
                },
                {
                    name: "Logout",
                    icon: "󰍃",
                    color: Colors.yellow,
                    cmd: ["hyprctl", "dispatch", "exit"]
                },
                {
                    name: "Reboot",
                    icon: "󰜉",
                    color: Colors.orange,
                    cmd: ["systemctl", "reboot"]
                },
                {
                    name: "Shutdown",
                    icon: "󰐥",
                    color: Colors.red,
                    cmd: ["systemctl", "poweroff"]
                }
            ]

            Rectangle {
                width: 60
                height: 60
                radius: 16

                // Animate to the specific action color on hover
                color: btnArea.containsMouse ? modelData.color : Colors.bg2
                border.color: btnArea.containsMouse ? modelData.color : Colors.bg3
                border.width: 2

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }
                Behavior on border.color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: modelData.icon
                    color: btnArea.containsMouse ? Colors.bg0 : Colors.fg0
                    font.family: Config.fontName
                    font.pixelSize: 24
                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }
                }

                MouseArea {
                    id: btnArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Quickshell.execDetached(modelData.cmd);
                        closeRequested(); // Close the menu after clicking
                    }
                }
            }
        }
    }
}
