import QtQuick
import Quickshell.Networking

Rectangle {
    id: root
    signal openMenuRequested

    property var wifiDevice: Networking.devices.values.find(d => d.type === DeviceType.Wifi)
    property var activeNetwork: wifiDevice ? wifiDevice.networks.values.find(n => n.connected) : null
    property bool isRadioOn: Networking.wifiEnabled
    property string currentSsid: activeNetwork ? activeNetwork.name : ""
    property real currentSignal: activeNetwork ? activeNetwork.signalStrength : 0
    property bool isHovered: menuArea.containsMouse || circleArea.containsMouse

    height: Config.ccToggleHeight
    radius: Config.ccToggleRadius
    color: isRadioOn ? (isHovered ? Qt.rgba(Colors.aqua.r, Colors.aqua.g, Colors.aqua.b, 0.85) : Colors.aqua) : (isHovered ? Colors.bg1 : Colors.bg0)
    border.color: Colors.bg3
    border.width: isRadioOn ? 0 : 1

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }

    function getWifiOpacity(sig) {
        if (root.currentSsid === "")
            return 1.0;
        if (sig >= 0.75)
            return 1.0;
        if (sig >= 0.50)
            return 0.75;
        if (sig >= 0.25)
            return 0.50;
        return 0.35;
    }

    Row {
        anchors.fill: parent
        anchors.margins: 6
        spacing: 12

        Rectangle {
            width: parent.height
            height: parent.height
            radius: width / 2
            color: root.isRadioOn ? (circleArea.containsMouse ? Qt.rgba(0, 0, 0, 0.45) : Qt.rgba(0, 0, 0, 0.30)) : (circleArea.containsMouse ? Colors.bg3 : Colors.bg2)

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }

            Text {
                anchors.centerIn: parent
                text: ""
                font.family: Config.fontName
                font.pixelSize: Config.fontSizeCcToggleIcon
                color: root.isRadioOn ? Colors.bg0 : Colors.fg0
                opacity: root.isRadioOn ? root.getWifiOpacity(root.currentSignal) : 0.6

                Behavior on opacity {
                    NumberAnimation {
                        duration: 300
                    }
                }
            }

            MouseArea {
                id: circleArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: {
                    Networking.wifiEnabled = !Networking.wifiEnabled;
                }
            }
        }

        Item {
            width: parent.width - parent.height - 18
            height: parent.height

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Text {
                    text: "Wi-Fi"
                    font.family: Config.fontName
                    font.pixelSize: Config.fontSizeCcToggleTitle
                    font.bold: true
                    color: root.isRadioOn ? Colors.bg0 : Colors.fg0
                }
                Text {
                    text: !root.isRadioOn ? "Off" : (root.currentSsid !== "" ? root.currentSsid : "On")
                    font.family: Config.fontName
                    font.pixelSize: Config.fontSizeCcToggleSub
                    color: root.isRadioOn ? Qt.rgba(Colors.bg0.r, Colors.bg0.g, Colors.bg0.b, 0.7) : Colors.fg3
                    width: parent.width
                    elide: Text.ElideRight
                }
            }

            MouseArea {
                id: menuArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: root.openMenuRequested()
            }
        }
    }
}
