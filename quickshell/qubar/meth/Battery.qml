import QtQuick
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Io
import ".."

Rectangle {
    id: batteryWidget
    width: 38
    height: 18
    radius: 11
    color: Colors.grey0
    anchors.verticalCenter: parent.verticalCenter
    property string activeProfile: ""
    Process {
        command: ["powerprofilesctl", "get"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                batteryWidget.activeProfile = data.trim();
            }
        }
    }
    readonly property int batPercent: UPower.displayDevice?.ready ? Math.round(UPower.displayDevice.percentage * 100) : 0
    readonly property bool isCharging: !UPower.onBattery
    Rectangle {
        id: fillBar
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: (batteryWidget.batPercent / 100) * (parent.width - 4)
        height: parent.height - 4
        radius: 9
        color: Colors.aqua
        anchors.leftMargin: 2
        Behavior on width {
            NumberAnimation {
                duration: 300
            }
        }
    }
    Text {
        anchors.centerIn: parent
        text: batteryWidget.isCharging ? "󱐋" : `${batteryWidget.batPercent}%`
        font.pixelSize: 12
        font.family: "JetBrainsMono Nerd Font"
        color: Colors.bg0
        font.bold: true
    }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: powerPopup.visible = !powerPopup.visible
    }
    PopupWindow {
        id: powerPopup
        anchor.item: batteryWidget
        anchor.edges: Edges.Bottom | Edges.Left

        width: 200
        height: 130
        visible: false

        color: "transparent"
        grabFocus: true

        onVisibleChanged: {
            if (visible) {
                powerBgRect.forceActiveFocus();
            }
        }

        Rectangle {
            id: powerBgRect
            anchors.fill: parent
            anchors.topMargin: 15

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
