import QtQuick
import Quickshell.Bluetooth

Rectangle {
    id: root
    signal openMenuRequested

    // qmllint disable unresolved-type
    property var adapter: Bluetooth.defaultAdapter
    property bool isRadioOn: adapter ? adapter.enabled : false
    property string currentDevice: ""

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            // qmllint disable unresolved-type
            if (!root.adapter || !root.adapter.enabled || !Bluetooth.devices) {
                root.currentDevice = "";
                return;
            }

            // qmllint disable unresolved-type
            let devs = Bluetooth.devices.values;
            let found = "";
            for (let i = 0; i < devs.length; i++) {
                if (devs[i].connected) {
                    found = devs[i].name || devs[i].deviceName || devs[i].address || "Connected";
                    break;
                }
            }
            root.currentDevice = found;
        }
    }

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

    function getBtIcon() {
        if (!isRadioOn)
            return "󰂲";
        if (currentDevice !== "")
            return "󰂱";
        return "󰂯";
    }

    // UI LAYOUT
    Row {
        anchors.fill: parent
        anchors.margins: 6
        spacing: 12

        // --- POWER BUTTON CIRCLE ---
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
                text: root.getBtIcon()
                font.family: Config.fontName
                font.pixelSize: Config.fontSizeCcToggleIcon

                color: root.isRadioOn ? Colors.bg0 : Colors.fg0
                opacity: root.isRadioOn ? 1.0 : 0.6
            }

            MouseArea {
                id: circleArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: {
                    if (root.adapter) {
                        root.adapter.enabled = !root.adapter.enabled;

                        if (!root.adapter.enabled) {
                            root.currentDevice = "";
                        }
                    }
                }
            }
        }

        // --- TEXT AND MENU TRIGGER ---
        Item {
            width: parent.width - parent.height - 18
            height: parent.height

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Text {
                    text: "Bluetooth"
                    font.family: Config.fontName
                    font.pixelSize: Config.fontSizeCcToggleTitle
                    font.bold: true
                    color: root.isRadioOn ? Colors.bg0 : Colors.fg0
                }
                Text {
                    text: !root.isRadioOn ? "Off" : (root.currentDevice !== "" ? root.currentDevice : "On")
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
