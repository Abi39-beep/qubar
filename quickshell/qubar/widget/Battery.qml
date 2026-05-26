import QtQuick
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Io
import ".."

Rectangle {
    id: batteryWidget
    width: 70
    height: 30
    radius: 15
    color: Colors.bg1
    border.width: 1
    border.color: Colors.bg2

    // This tracks the profile visually. We leave it blank at first.
    property string activeProfile: ""

    // FIX: Changed from StringParser to SplitParser
    Process {
        command: ["powerprofilesctl", "get"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                // It reads the output (e.g., "performance") and assigns it
                batteryWidget.activeProfile = data.trim();
            }
        }
    }

    // Live battery properties
    readonly property int batPercent: UPower.displayDevice?.ready ? Math.round(UPower.displayDevice.percentage * 100) : 0
    readonly property bool isCharging: !UPower.onBattery

    Row {
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: batteryWidget.isCharging ? "󰂄" : "󰁹"
            font.pixelSize: 13
            font.family: "JetBrainsMono Nerd Font"
            color: Colors.aqua
        }

        Text {
            text: `${batteryWidget.batPercent}%`
            font.pixelSize: 13
            font.family: "JetBrainsMono Nerd Font"
            color: Colors.aqua
            font.bold: true
        }
    }

    // Toggle Popup on click
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: powerPopup.visible = !powerPopup.visible
    }

    // --- FLOATING POWER PROFILE POPUP ---
    PopupWindow {
        id: powerPopup
        anchor.item: batteryWidget
        anchor.edges: Edges.Bottom | Edges.Left

        width: 200
        height: 120
        visible: false

        color: "transparent"
        grabFocus: true

        // Force keyboard grab when opened
        onVisibleChanged: {
            if (visible) {
                powerBgRect.forceActiveFocus();
            }
        }

        Rectangle {
            id: powerBgRect
            anchors.fill: parent
            anchors.topMargin: 10

            // Escape key & Click-away logic
            focus: true
            Keys.onEscapePressed: powerPopup.visible = false
            onActiveFocusChanged: {
                if (!activeFocus) {
                    powerPopup.visible = false;
                }
            }

            color: Qt.alpha(Colors.bg0, 0.95)
            border.color: Colors.grey0
            border.width: 1
            radius: 8

            Column {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 4

                Text {
                    text: "Power Profile"
                    font.pixelSize: 14
                    font.bold: true
                    color: Colors.grey1
                    bottomPadding: 4
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Repeater {
                    model: [
                        {
                            name: "Performance ",
                            cmd: "performance"
                        },
                        {
                            name: "Balanced ",
                            cmd: "balanced"
                        },
                        {
                            name: "Power Saver ",
                            cmd: "power-saver"
                        }
                    ]

                    Rectangle {
                        required property var modelData
                        width: parent.width
                        height: 22
                        radius: 4

                        readonly property bool isCurrent: batteryWidget.activeProfile === modelData.cmd
                        color: isCurrent ? Colors.bg3 : (btnMouse.containsMouse ? Colors.bg2 : "transparent")

                        Text {
                            anchors.centerIn: parent
                            text: isCurrent ? "● " + modelData.name : "  " + modelData.name
                            color: isCurrent ? Colors.green : Colors.fg
                            font.pixelSize: 14
                            font.family: "JetBrainsMono Nerd Font"
                        }

                        MouseArea {
                            id: btnMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                Quickshell.execDetached(["powerprofilesctl", "set", modelData.cmd]);
                                batteryWidget.activeProfile = modelData.cmd;
                                powerPopup.visible = false;
                            }
                        }
                    }
                }
            }
        }
    }
}
