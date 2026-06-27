import QtQuick
import Quickshell
import Quickshell.Bluetooth

Item {
    id: btMenuRoot
    signal backRequested

    property string expandedMac: ""

    // ==========================================
    // 1. NATIVE STATE ENGINE
    // ==========================================
    property var adapter: Bluetooth.defaultAdapter
    property bool isRadioOn: adapter ? adapter.enabled : false

    // Smart Scanning: Only scan quietly in the background while the menu is open
    onVisibleChanged: {
        if (visible) {
            if (adapter && !adapter.discovering && adapter.enabled) {
                adapter.discovering = true;
            }
            sortTrigger++; // Force an initial sort when opened
        } else {
            expandedMac = "";
            if (adapter && adapter.discovering) {
                adapter.discovering = false;
            }
        }
    }

    // ==========================================
    // 2. THE ZERO-LAG BUBBLE SORT ENGINE
    // Constantly keeps connected devices at the top automatically
    // ==========================================
    property int sortTrigger: 0

    // Lightweight 1-second pulse to refresh the order
    Timer {
        interval: 1000
        running: btMenuRoot.visible
        repeat: true
        onTriggered: btMenuRoot.sortTrigger++
    }

    function getSortedDevices() {
        let dummy = sortTrigger; // Subscribes to the timer pulse

        if (!adapter || !adapter.enabled || !Bluetooth.devices)
            return [];

        let devs = [];
        let raw = Bluetooth.devices.values;
        if (raw) {
            for (let i = 0; i < raw.length; i++) {
                devs.push(raw[i]);
            }
        }

        // The sorting magic: pushes connected devices to the front!
        devs.sort((a, b) => {
            let aConn = a.connected ? 1 : 0;
            let bConn = b.connected ? 1 : 0;
            return bConn - aConn;
        });

        return devs;
    }

    // ==========================================
    // 3. UI LAYOUT
    // ==========================================
    Column {
        anchors.fill: parent
        spacing: 16

        // --- HEADER ---
        Item {
            width: parent.width
            height: 36

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                Rectangle {
                    width: 36
                    height: 36
                    radius: 18
                    color: backArea.containsMouse ? Colors.bg2 : Colors.bg1
                    border.color: Colors.bg3
                    border.width: 1

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "󰁍"
                        font.family: Config.fontName
                        font.pixelSize: 18
                        color: Colors.fg0
                    }
                    MouseArea {
                        id: backArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: btMenuRoot.backRequested()
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Bluetooth Devices"
                    font.family: Config.fontName
                    font.pixelSize: 16
                    font.bold: true
                    color: Colors.fg0
                }
            }

            // --- HEADER RIGHT CONTROLS ---
            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                // THE VISUAL SCAN BUTTON HAS BEEN COMPLETELY REMOVED!

                // POWER TOGGLE
                Item {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 44
                    height: 36

                    Rectangle {
                        anchors.centerIn: parent
                        width: 38
                        height: 22
                        radius: 11

                        color: btMenuRoot.isRadioOn ? (pwrArea.containsMouse ? Qt.rgba(Colors.aqua.r, Colors.aqua.g, Colors.aqua.b, 0.8) : Colors.aqua) : (pwrArea.containsMouse ? Colors.bg2 : Colors.bg1)
                        border.color: btMenuRoot.isRadioOn ? Colors.aqua : Colors.bg3
                        border.width: 1

                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                            }
                        }

                        Rectangle {
                            width: 14
                            height: 14
                            radius: 7
                            anchors.verticalCenter: parent.verticalCenter
                            x: btMenuRoot.isRadioOn ? parent.width - width - 4 : 4
                            color: btMenuRoot.isRadioOn ? Colors.bg0 : (pwrArea.containsMouse ? Colors.fg2 : Colors.fg3)

                            Behavior on x {
                                NumberAnimation {
                                    duration: 200
                                    easing.type: Easing.OutQuart
                                }
                            }
                            Behavior on color {
                                ColorAnimation {
                                    duration: 200
                                }
                            }
                        }
                    }

                    MouseArea {
                        id: pwrArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            if (adapter) {
                                adapter.enabled = !adapter.enabled;
                                if (!adapter.enabled && adapter.discovering) {
                                    adapter.discovering = false;
                                } else if (adapter.enabled) {
                                    adapter.discovering = true; // Start scanning silently when turned back on
                                }
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Colors.bg3
        }

        // --- DYNAMIC BLUETOOTH LIST ---
        Flickable {
            width: parent.width
            height: parent.height - 69
            contentHeight: listCol.height
            clip: true
            interactive: true

            Column {
                id: listCol
                width: parent.width
                spacing: 8

                Repeater {
                    // THE FIX: Binds perfectly to our custom auto-sorting function
                    model: btMenuRoot.getSortedDevices()

                    Rectangle {
                        id: btBox
                        width: parent.width

                        property string mac: modelData.address || ""
                        property bool isActive: modelData.connected || false
                        property string devName: modelData.name || modelData.deviceName || mac

                        property bool isExpanded: btMenuRoot.expandedMac === mac

                        height: isExpanded ? 96 : 48
                        radius: 12
                        clip: true

                        color: isActive ? Qt.rgba(Colors.aqua.r, Colors.aqua.g, Colors.aqua.b, 0.15) : (btMouseArea.containsMouse ? Colors.bg3 : Colors.bg2)
                        border.color: isActive ? Colors.aqua : (btMouseArea.containsMouse ? Colors.fg3 : Colors.bg3)
                        border.width: 1

                        Behavior on height {
                            NumberAnimation {
                                duration: 250
                                easing.type: Easing.OutQuart
                            }
                        }
                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }
                        Behavior on border.color {
                            ColorAnimation {
                                duration: 150
                            }
                        }

                        Item {
                            width: parent.width
                            height: 48

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 16
                                anchors.right: statusBadge.visible ? statusBadge.left : parent.right
                                anchors.rightMargin: 16
                                text: parent.parent.devName
                                font.family: Config.fontName
                                font.pixelSize: 14
                                font.bold: parent.parent.isActive
                                color: parent.parent.isActive ? Colors.aqua : Colors.fg0
                                elide: Text.ElideRight
                            }

                            Text {
                                id: statusBadge
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                anchors.rightMargin: 16
                                visible: parent.parent.isActive
                                text: "Connected"
                                color: Colors.aqua
                                font.family: Config.fontName
                                font.pixelSize: 12
                                font.bold: true
                            }

                            MouseArea {
                                id: btMouseArea
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onClicked: btMenuRoot.expandedMac = (btMenuRoot.expandedMac === parent.parent.mac) ? "" : parent.parent.mac
                            }
                        }

                        Item {
                            y: 48
                            width: parent.width
                            height: parent.height - 48
                            opacity: btBox.isExpanded ? 1 : 0
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 250
                                }
                            }

                            Row {
                                anchors.fill: parent
                                anchors.margins: 12
                                anchors.topMargin: 0
                                spacing: 12

                                Rectangle {
                                    width: (parent.width - 12) / 2
                                    height: 36
                                    radius: 8

                                    color: btBox.isActive ? (connArea.containsMouse ? Colors.bg3 : Colors.bg2) : (connArea.containsMouse ? Qt.rgba(Colors.aqua.r, Colors.aqua.g, Colors.aqua.b, 0.8) : Colors.aqua)
                                    border.color: btBox.isActive ? Colors.bg3 : Colors.aqua
                                    border.width: 1

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 150
                                        }
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        text: btBox.isActive ? "Disconnect" : "Connect"
                                        color: btBox.isActive ? Colors.fg0 : Colors.bg0
                                        font.family: Config.fontName
                                        font.pixelSize: 13
                                        font.bold: true
                                    }

                                    MouseArea {
                                        id: connArea
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        hoverEnabled: true
                                        onClicked: {
                                            let cmd = btBox.isActive ? "bluetoothctl disconnect '" + btBox.mac + "'" : "bluetoothctl pair '" + btBox.mac + "'; bluetoothctl trust '" + btBox.mac + "'; bluetoothctl connect '" + btBox.mac + "'";
                                            Quickshell.execDetached(["bash", "-c", cmd]);
                                            btMenuRoot.expandedMac = "";
                                            btMenuRoot.sortTrigger++; // Instantly bumps it after clicking!
                                        }
                                    }
                                }

                                Rectangle {
                                    width: (parent.width - 12) / 2
                                    height: 36
                                    radius: 8
                                    color: forgetArea.containsMouse ? Qt.rgba(Colors.red.r, Colors.red.g, Colors.red.b, 0.8) : Colors.red

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 150
                                        }
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        text: "Forget"
                                        color: Colors.bg0
                                        font.family: Config.fontName
                                        font.pixelSize: 13
                                        font.bold: true
                                    }

                                    MouseArea {
                                        id: forgetArea
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        hoverEnabled: true
                                        onClicked: {
                                            Quickshell.execDetached(["bash", "-c", "bluetoothctl remove '" + btBox.mac + "'"]);
                                            btMenuRoot.expandedMac = "";
                                            btMenuRoot.sortTrigger++;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
