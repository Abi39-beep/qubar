import QtQuick
import Quickshell.Bluetooth
import ".."

Rectangle {
    id: root
    signal openMenu

    property var adapter: Bluetooth.defaultAdapter
    readonly property bool isRadioOn: adapter ? adapter.enabled : false
    property string currentDevice: ""

    property bool _hasAutoConnected: false
    property var _pendingDevices: []

    onIsRadioOnChanged: {
        if (isRadioOn && !_hasAutoConnected) {
            _hasAutoConnected = true;
            if (Bluetooth.devices) {
                let devs = Bluetooth.devices.values;
                _pendingDevices = [];

                for (let i = 0; i < devs.length; i++) {
                    if (devs[i].trusted && !devs[i].connected) {
                        _pendingDevices.push(devs[i]);
                    }
                }

                _pendingDevices.sort((a, b) => {
                    let aIsAudio = (a.icon && a.icon.indexOf("audio") !== -1) ? 1 : 0;
                    let bIsAudio = (b.icon && b.icon.indexOf("audio") !== -1) ? 1 : 0;
                    return bIsAudio - aIsAudio;
                });

                if (_pendingDevices.length > 0) {
                    autoConnectQueueTimer.start();
                }
            }
        }
        if (!isRadioOn) {
            _hasAutoConnected = false;
            autoConnectQueueTimer.stop();
            _pendingDevices = [];
        }
    }

    Timer {
        id: autoConnectQueueTimer
        interval: 1000
        repeat: true
        onTriggered: {
            if (root._pendingDevices.length === 0) {
                stop();
                return;
            }

            if (!Bluetooth.devices)
                return;
            let devs = Bluetooth.devices.values;

            for (let i = 0; i < devs.length; i++) {
                if (devs[i].state === BluetoothDeviceState.Connecting) {
                    return;
                }
            }

            let dev = root._pendingDevices.shift();
            if (dev && !dev.connected && typeof dev.connect === "function") {
                dev.connect();
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            if (!root.adapter || !root.adapter.enabled || !Bluetooth.devices) {
                root.currentDevice = "";
                return;
            }
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

    width: parent.width
    height: 56
    radius: 28

    color: isRadioOn ? (isHovered ? Qt.rgba(Colors.aqua.r, Colors.aqua.g, Colors.aqua.b, 0.85) : Colors.aqua) : (isHovered ? Colors.bg1 : Colors.bg0)
    border.color: Colors.bg3
    border.width: isRadioOn ? 0 : 2

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

    Row {
        anchors.fill: parent
        anchors.margins: 6
        spacing: 12

        Rectangle {
            width: 44
            height: 44
            radius: 22
            color: root.isRadioOn ? (circleArea.containsMouse ? Qt.rgba(0, 0, 0, 0.45) : Qt.rgba(0, 0, 0, 0.30)) : (circleArea.containsMouse ? Colors.bg3 : Colors.bg2)
            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }

            Text {
                anchors.centerIn: parent
                text: root.getBtIcon()
                font.family: "SF Pro Display"
                font.pixelSize: 18
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

        Item {
            width: parent.width - 56
            height: parent.height

            Column {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 2

                Text {
                    text: "Bluetooth"
                    font.family: "SF Pro Display"
                    font.pixelSize: 14
                    font.bold: true
                    color: root.isRadioOn ? Colors.bg0 : Colors.fg0
                }

                Text {
                    text: !root.isRadioOn ? "Off" : (root.currentDevice !== "" ? root.currentDevice : "On")
                    font.family: "SF Pro Display"
                    font.pixelSize: 12
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
                onClicked: root.openMenu()
            }
        }
    }
}
