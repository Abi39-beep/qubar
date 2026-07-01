import QtQuick
import Quickshell
import Quickshell.Bluetooth

Item {
    id: btMenuRoot

    // Use fixed dimensions for a standalone window
    width: 360
    height: mainCol.implicitHeight

    signal closeMenu

    property string expandedMac: ""
    property var adapter: Bluetooth.defaultAdapter
    property bool isRadioOn: adapter ? adapter.enabled : false
    property var activeDeviceList: []

    onVisibleChanged: {
        if (visible) {
            if (adapter && !adapter.discovering && adapter.enabled)
                adapter.discovering = true;
            updateDeviceList();
        } else {
            expandedMac = "";
            if (adapter && adapter.discovering)
                adapter.discovering = false;
        }
    }

    Timer {
        interval: 1000
        running: btMenuRoot.visible
        repeat: true
        onTriggered: updateDeviceList()
    }

    function updateDeviceList() {
        if (btMenuRoot.expandedMac !== "")
            return;
        if (!adapter || !adapter.enabled || !Bluetooth.devices) {
            activeDeviceList = [];
            return;
        }
        let devs = Bluetooth.devices.values;
        devs.sort((a, b) => (b.connected ? 1 : 0) - (a.connected ? 1 : 0));
        activeDeviceList = devs;
    }

    Column {
        id: mainCol
        width: 360
        spacing: 16

        // HEADER
        Item {
            width: 360
            height: 36
            Row {
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12
                Rectangle {
                    width: 36
                    height: 36
                    radius: 18
                    color: Colors.bg1
                    Text {
                        anchors.centerIn: parent
                        text: "←"
                        color: Colors.fg0
                        font.pixelSize: 18
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: btMenuRoot.closeMenu()
                    }
                }
                Text {
                    text: "Bluetooth"
                    color: Colors.fg0
                    font.pixelSize: 16
                    font.bold: true
                }
            }
        }

        // LIST
        Repeater {
            model: btMenuRoot.activeDeviceList
            delegate: Rectangle {
                width: 360
                height: 48
                color: modelData.connected ? Colors.blue : Colors.bg2
                radius: 12
                Text {
                    anchors.centerIn: parent
                    text: modelData.name || modelData.address
                    color: modelData.connected ? Colors.bg0 : Colors.fg0
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (modelData.connected)
                            modelData.disconnect();
                        else
                            modelData.connect();
                    }
                }
            }
        }
    }
}
