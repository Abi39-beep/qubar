import QtQuick
import Quickshell.Bluetooth
import ".."

Item {
    id: btMenuRoot

    height: mainCol.implicitHeight
    signal closeMenu

    property string expandedMac: ""
    property var adapter: Bluetooth.defaultAdapter
    readonly property bool isRadioOn: adapter ? adapter.enabled : false
    property var activeDeviceList: []

    onVisibleChanged: {
        if (visible) {
            if (adapter && !adapter.discovering && adapter.enabled) {
                adapter.discovering = true;
            }
            updateDeviceList();
        } else {
            expandedMac = "";
            if (adapter && adapter.discovering) {
                adapter.discovering = false;
            }
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

        let raw = Bluetooth.devices.values;
        let devs = [];
        for (let i = 0; i < raw.length; i++) {
            devs.push(raw[i]);
        }

        devs.sort((a, b) => {
            let aConn = a.connected ? 1 : 0;
            let bConn = b.connected ? 1 : 0;
            return bConn - aConn;
        });

        activeDeviceList = devs;
    }

    Column {
        id: mainCol
        width: parent.width
        spacing: 16

        // 1. THE HEADER
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
                        text: "←"
                        font.family: "SF Pro Display"
                        font.pixelSize: 18
                        color: Colors.fg0
                    }

                    MouseArea {
                        id: backArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: btMenuRoot.closeMenu()
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Bluetooth Devices"
                    font.family: "SF Pro Display"
                    font.pixelSize: 16
                    font.bold: true
                    color: Colors.fg0
                }
            }

            // HEADER RIGHT CONTROLS
            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

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
                                if (!adapter.enabled && adapter.discovering)
                                    adapter.discovering = false;
                                else if (adapter.enabled)
                                    adapter.discovering = true;
                            }
                        }
                    }
                }
            }
        }

        // 2. DYNAMIC BLUETOOTH LIST
        Flickable {
            width: parent.width
            height: Math.min(listCol.implicitHeight, 400)
            contentHeight: listCol.implicitHeight
            clip: true
            interactive: true

            Column {
                id: listCol
                width: parent.width
                spacing: 8

                Repeater {
                    model: btMenuRoot.activeDeviceList

                    Rectangle {
                        id: btBox
                        width: parent.width

                        property string mac: modelData.address ? modelData.address : "dev_" + index
                        property bool isActive: modelData.connected || false
                        property bool isTrusted: modelData.trusted || false
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
                                font.family: "SF Pro Display"
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
                                font.family: "SF Pro Display"
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

                        // EXPANDED ACTION AREA
                        Item {
                            id: actionArea
                            y: 48
                            width: parent.width
                            height: parent.height - 48
                            opacity: btBox.isExpanded ? 1 : 0
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 250
                                }
                            }

                            property bool showTrust: btBox.isActive && !btBox.isTrusted
                            property real btnWidth: showTrust ? (width - 48) / 3 : (width - 36) / 2

                            Row {
                                anchors.fill: parent
                                anchors.margins: 12
                                anchors.topMargin: 0
                                spacing: 12

                                // 1. CONNECT / DISCONNECT BUTTON
                                Rectangle {
                                    width: actionArea.btnWidth
                                    height: 36
                                    radius: 8

                                    color: btBox.isActive ? (connArea.containsMouse ? Colors.bg3 : Colors.bg2) : (connArea.containsMouse ? Qt.rgba(Colors.aqua.r, Colors.aqua.g, Colors.aqua.b, 0.8) : Colors.aqua)
                                    border.color: btBox.isActive ? Colors.bg3 : Colors.aqua
                                    border.width: 1

                                    Behavior on width {
                                        NumberAnimation {
                                            duration: 200
                                            easing.type: Easing.OutQuart
                                        }
                                    }

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 150
                                        }
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        text: btBox.isActive ? "Disconnect" : "Connect"
                                        color: btBox.isActive ? Colors.fg0 : Colors.bg0
                                        font.family: "SF Pro Display"
                                        font.pixelSize: 13
                                        font.bold: true
                                    }

                                    MouseArea {
                                        id: connArea
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        hoverEnabled: true

                                        onClicked: {
                                            if (btBox.isActive) {
                                                if (typeof modelData.disconnect === "function")
                                                    modelData.disconnect();
                                            } else {
                                                if (typeof modelData.connect === "function")
                                                    modelData.connect();
                                            }
                                        }
                                    }
                                }

                                // 2. NEW TRUST BUTTON
                                Rectangle {
                                    visible: actionArea.showTrust
                                    width: actionArea.showTrust ? actionArea.btnWidth : 0
                                    opacity: actionArea.showTrust ? 1 : 0
                                    height: 36
                                    radius: 8
                                    clip: true

                                    color: trustArea.containsMouse ? Qt.rgba(Colors.green.r, Colors.green.g, Colors.green.b, 0.8) : Colors.green

                                    Behavior on width {
                                        NumberAnimation {
                                            duration: 200
                                            easing.type: Easing.OutQuart
                                        }
                                    }

                                    Behavior on opacity {
                                        NumberAnimation {
                                            duration: 200
                                        }
                                    }

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 150
                                        }
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        text: "Trust"
                                        color: Colors.bg0
                                        font.family: "SF Pro Display"
                                        font.pixelSize: 13
                                        font.bold: true
                                    }

                                    MouseArea {
                                        id: trustArea
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        hoverEnabled: true

                                        onClicked: {
                                            try {
                                                modelData.trusted = true;
                                            } catch (e) {
                                                console.log("Trust assignment error: " + e);
                                            }

                                            try {
                                                if (typeof modelData.pair === "function") {
                                                    modelData.pair();
                                                }
                                            } catch (e) {}
                                        }
                                    }
                                }

                                // 3. FORGET BUTTON
                                Rectangle {
                                    width: actionArea.btnWidth
                                    height: 36
                                    radius: 8
                                    color: forgetArea.containsMouse ? Qt.rgba(Colors.red.r, Colors.red.g, Colors.red.b, 0.8) : Colors.red

                                    Behavior on width {
                                        NumberAnimation {
                                            duration: 200
                                            easing.type: Easing.OutQuart
                                        }
                                    }

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 150
                                        }
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        text: "Forget"
                                        color: Colors.bg0
                                        font.family: "SF Pro Display"
                                        font.pixelSize: 13
                                        font.bold: true
                                    }

                                    MouseArea {
                                        id: forgetArea
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        hoverEnabled: true

                                        onClicked: {
                                            if (btBox.isActive && typeof modelData.disconnect === "function") {
                                                modelData.disconnect();
                                            }

                                            if (typeof modelData.forget === "function")
                                                modelData.forget();
                                            else if (typeof modelData.remove === "function")
                                                modelData.remove();

                                            btMenuRoot.expandedMac = "";
                                            btMenuRoot.updateDeviceList();
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
