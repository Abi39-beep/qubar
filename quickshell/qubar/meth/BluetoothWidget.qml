import Quickshell.Bluetooth
import QtQuick
import QtQuick.Layouts
import ".."

RowLayout {
    id: root
    spacing: 6

    signal openBtMenu()

    property var adapter: Bluetooth.defaultAdapter
    readonly property bool isBtOn: adapter ? adapter.enabled : false
    readonly property bool isConnected: Bluetooth.devices.values.some(d => d.connected)

    Text {
        Layout.preferredWidth: 22
        horizontalAlignment: Text.AlignHCenter

        text: root.isBtOn ? "󰂯" : "󰂲"
        color: root.isBtOn ? Colors.orange : Colors.grey1

        font {
            family: "JetBrainsMono Nerd Font Propo"
            pixelSize: 18
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.openBtMenu()
        }
    }

    Text {
        visible: root.isConnected

        Layout.preferredWidth: 22
        horizontalAlignment: Text.AlignHCenter

        text: "󰂱"
        color: Colors.blue

        font {
            family: "JetBrainsMono Nerd Font Propo"
            pixelSize: 18
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.openBtMenu()
        }
    }
}
