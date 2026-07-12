import Quickshell.Networking
import QtQuick
import QtQuick.Layouts
import ".."

RowLayout {
    id: root
    spacing: 6

    signal openWifiMenu()

    property var wifiDevice: Networking.devices.values.find(d => d.type === DeviceType.Wifi)
    property var active: wifiDevice ? wifiDevice.networks.values.find(n => n.connected) : null

    readonly property real signalStrengthValue: active ? active.signalStrength : 0

    readonly property string icon: {
        if (!Networking.wifiEnabled)
            return String.fromCodePoint(0xF05AA);
        if (!active)
            return String.fromCodePoint(0xF092D);

        let tier = signalStrengthValue >= 0.75 ? 4 : signalStrengthValue >= 0.50 ? 3 : signalStrengthValue >= 0.25 ? 2 : 1;
        return String.fromCodePoint(0xF091F + (tier - 1) * 3);
    }

    Text {
        Layout.preferredWidth: 22
        horizontalAlignment: Text.AlignHCenter

        text: root.icon
        color: Networking.wifiEnabled ? Colors.purple : Colors.grey1

        font {
            family: "JetBrainsMono Nerd Font Propo"
            pixelSize: 18
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.openWifiMenu()
        }
    }
}
