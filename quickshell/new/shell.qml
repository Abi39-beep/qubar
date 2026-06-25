import Quickshell
import QtQuick
import QtQuick.Layouts

ShellRoot {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }
            implicitHeight: 38
            color: Colors.bg0

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                spacing: 8

                Workspaces {}

                Item {
                    Layout.fillWidth: true
                }

                RowLayout {
                    spacing: 25

                    Brightness {}
                    Volume {}
                    Networking {}
                    Battery {}
                    Clock {}
                }
            }
        }
    }
}
