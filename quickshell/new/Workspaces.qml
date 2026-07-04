import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

RowLayout {
    spacing: 6

    Repeater {
        model: 5

        Rectangle {
            id: wsBotton
            required property int index

            property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
            property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)

            implicitWidth: label.implicitWidth + 14
            implicitHeight: 22
            radius: 6
            color: isActive ? Colors.aqua : (ws ? Colors.bg2 : "transparent")

            Behavior on color {
                ColorAnimation {
                    duration: 85
                }
            }

            Text {
                id: label
                anchors.centerIn: parent
                text: wsBotton.index + 1
                color: wsBotton.isActive ? Colors.bg0 : (wsBotton.ws ? Colors.fg : Colors.grey1)

                font {
                    family: "SF Pro Display"
                    pixelSize: 14
                    weight: 500
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + (parent.index + 1) + "})")
            }
        }
    }
}
