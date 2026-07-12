import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts
import ".."

RowLayout {
    id: root
    spacing: 6

signal openProfileMenu()

    property var battery: UPower.displayDevice
    property bool charging: battery ? battery.state === UPowerDeviceState.Charging : false
    readonly property int level: battery ? Math.round(battery.percentage * 100) : 0

    property color indicatorColor: root.charging ? Colors.green : (root.level <= 15 ? Colors.red : (root.level <= 30 ? Colors.orange : Colors.green))

    Item {
        Layout.preferredWidth: 41
        Layout.preferredHeight: 16
        Layout.alignment: Qt.AlignVCenter

        Rectangle {
            id: batteryBody
            width: 38
            height: 16
            radius: 3
            anchors.verticalCenter: parent.verticalCenter
            color: "transparent"
            border.width: 1
            border.color: root.indicatorColor

            Behavior on border.color { ColorAnimation { duration: 150 } }

            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.margins: 2

                width: (root.level / 100) * 34
                radius: 1
                color: root.indicatorColor

                Behavior on width {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.OutExpo
                    }
                }
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            Row {
                anchors.centerIn: parent
                spacing: 1

                Text {
                    visible: root.charging
                    anchors.verticalCenter: parent.verticalCenter
                    text: "󱐋"
                    color: Colors.bg0
                    font.pixelSize: 10
                    font.family: "JetBrainsMono Nerd Font Propo"
                    font.bold: true
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.level
                    color: Colors.bg0
                    font {
                        family: "SF Mono"
                        weight: 800
                        pixelSize: 10
                    }
                }
            }
        }

        Rectangle {
            anchors.left: batteryBody.right
            anchors.leftMargin: 1
            anchors.verticalCenter: batteryBody.verticalCenter
            width: 2
            height: 6
            radius: 1
            color: root.indicatorColor

            Behavior on color { ColorAnimation { duration: 150 } }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.openProfileMenu()
        }
    }
}
