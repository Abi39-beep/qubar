import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import ".."

RowLayout {
    id: root
    spacing: 5
    width: 146

    Row {
        Layout.alignment: Qt.AlignCenter
        spacing: 5

        Repeater {
            model: 5

            Rectangle {
                id: wsBtn
                required property int index

                readonly property int wsId: index + 1
                property var ws: Hyprland.workspaces.values.find(w => w.id === wsId)
                readonly property bool isActive: Hyprland.focusedWorkspace?.id === wsId
                readonly property bool isOccupied: ws ? ws.toplevels.values.length > 0 : false

                width: isActive ? 50 : 19
                height: 19
                radius: 15

                Behavior on width {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.OutExpo
                    }
                }

                color: isActive ? Colors.aqua : (isOccupied ? Colors.bg3 : Colors.bg1)
                border.width: isActive ? 0 : 1
                border.color: isOccupied ? Colors.grey0 : Colors.bg2

                Behavior on color {
                    ColorAnimation {
                        duration: 85
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: wsBtn.wsId
                    font.pixelSize: 13
                    font.family: "JetBrainsMono Nerd Font Propo"
                    font.bold: wsBtn.isActive
                    color: wsBtn.isActive ? Colors.bg0 : (wsBtn.isOccupied ? Colors.fg : Colors.grey1)
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch(`hl.dsp.focus({workspace = "${wsBtn.wsId}"})`)
                }
            }
        }
    }
}
