import QtQuick
import Quickshell.Networking

Item {
    id: wifiMenuRoot
    height: mainCol.implicitHeight

    signal closeMenu

    property string expandedSsid: ""
    property var wifiDevice: Networking.devices.values.find(d => d.type === DeviceType.Wifi)
    property bool isRadioOn: Networking.wifiEnabled
    property var activeNetworkList: []

    // --- LOGIC: AUTO-SCAN & REFRESH ---
    onVisibleChanged: {
        if (visible) {
            if (wifiDevice && isRadioOn && wifiDevice.requestScan) {
                wifiDevice.requestScan();
            }
            updateNetworkList();
        } else {
            expandedSsid = "";
        }
    }

    Timer {
        interval: 1000
        running: wifiMenuRoot.visible
        repeat: true
        onTriggered: updateNetworkList()
    }

    function updateNetworkList() {
        if (wifiMenuRoot.expandedSsid !== "")
            return;

        if (!wifiDevice || !isRadioOn || !wifiDevice.networks) {
            activeNetworkList = [];
            return;
        }

        let nets = wifiDevice.networks.values;
        let devs = [];

        for (let i = 0; i < nets.length; i++) {
            if (!nets[i].name)
                continue;

            devs.push({
                networkObj: nets[i],
                ssid: nets[i].name,
                isActive: nets[i].connected,
                signal: nets[i].signalStrength || 0
            });
        }

        devs.sort((a, b) => {
            let aConn = a.isActive ? 1 : 0;
            let bConn = b.isActive ? 1 : 0;
            if (aConn !== bConn)
                return bConn - aConn;
            return b.signal - a.signal;
        });

        activeNetworkList = devs;
    }

    // --- UI LAYOUT ---
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
                        onClicked: wifiMenuRoot.closeMenu()
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Wi-Fi Networks"
                    font.family: "SF Pro Display"
                    font.pixelSize: 16
                    font.bold: true
                    color: Colors.fg0
                }
            }

            // POWER TOGGLE BUTTON
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
                        color: wifiMenuRoot.isRadioOn ? (pwrArea.containsMouse ? Qt.rgba(Colors.aqua.r, Colors.aqua.g, Colors.aqua.b, 0.8) : Colors.aqua) : (pwrArea.containsMouse ? Colors.bg2 : Colors.bg1)
                        border.color: wifiMenuRoot.isRadioOn ? Colors.aqua : Colors.bg3
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
                            x: wifiMenuRoot.isRadioOn ? parent.width - width - 4 : 4
                            color: wifiMenuRoot.isRadioOn ? Colors.bg0 : (pwrArea.containsMouse ? Colors.fg2 : Colors.fg3)

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
                            Networking.wifiEnabled = !Networking.wifiEnabled;
                            if (Networking.wifiEnabled && wifiDevice && wifiDevice.requestScan) {
                                wifiDevice.requestScan();
                            }
                        }
                    }
                }
            }
        }

        // 2. THE DYNAMIC NETWORK LIST
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
                    model: wifiMenuRoot.activeNetworkList

                    Rectangle {
                        id: netBox
                        width: parent.width
                        property bool isExpanded: wifiMenuRoot.expandedSsid === modelData.ssid

                        onIsExpandedChanged: {
                            if (!isExpanded) {
                                passInput.text = "";
                                passCol.showPass = false;
                            }
                        }

                        height: isExpanded ? (modelData.isActive ? 104 : 124) : 48
                        radius: 12
                        clip: true
                        color: modelData.isActive ? Qt.rgba(Colors.aqua.r, Colors.aqua.g, Colors.aqua.b, 0.15) : (netMouseArea.containsMouse ? Colors.bg3 : Colors.bg2)
                        border.color: modelData.isActive ? Colors.aqua : (netMouseArea.containsMouse ? Colors.fg3 : Colors.bg3)
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

                        // A. TOP ROW (Network Name)
                        Item {
                            width: parent.width
                            height: 48

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 16
                                anchors.right: statusBadge.visible ? statusBadge.left : parent.right
                                anchors.rightMargin: 16
                                text: modelData.ssid
                                font.family: "SF Pro Display"
                                font.pixelSize: 14
                                font.bold: modelData.isActive
                                color: modelData.isActive ? Colors.aqua : Colors.fg0
                                elide: Text.ElideRight
                            }

                            Text {
                                id: statusBadge
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                anchors.rightMargin: 16
                                visible: modelData.isActive
                                text: "Connected"
                                color: Colors.aqua
                                font.family: "SF Pro Display"
                                font.pixelSize: 12
                                font.bold: true
                            }

                            MouseArea {
                                id: netMouseArea
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true

                                onClicked: {
                                    if (wifiMenuRoot.expandedSsid === modelData.ssid) {
                                        wifiMenuRoot.expandedSsid = "";
                                        wifiMenuRoot.updateNetworkList();
                                    } else {
                                        wifiMenuRoot.expandedSsid = modelData.ssid;
                                        if (!modelData.isActive) {
                                            passInput.forceActiveFocus();
                                        }
                                    }
                                }
                            }
                        }

                        // B. EXPANDED ACTION AREA
                        Item {
                            y: 48
                            width: parent.width
                            height: parent.height - 48
                            opacity: netBox.isExpanded ? 1 : 0
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 250
                                }
                            }

                            // PASSWORD INPUT
                            Column {
                                id: passCol
                                anchors.fill: parent
                                anchors.margins: 12
                                anchors.topMargin: 0
                                spacing: 8
                                visible: !modelData.isActive

                                property bool showPass: false

                                Rectangle {
                                    width: parent.width
                                    height: 36
                                    radius: 8
                                    color: "transparent"
                                    border.color: Colors.aqua
                                    border.width: 1

                                    TextInput {
                                        id: passInput
                                        anchors.left: parent.left
                                        anchors.right: eyeBtn.left
                                        anchors.top: parent.top
                                        anchors.bottom: parent.bottom
                                        anchors.leftMargin: 10
                                        anchors.rightMargin: 10
                                        verticalAlignment: TextInput.AlignVCenter

                                        color: Colors.fg0
                                        font.family: "SF Pro Display"
                                        font.pixelSize: 14
                                        echoMode: passCol.showPass ? TextInput.Normal : TextInput.Password
                                        clip: true

                                        selectByMouse: true
                                        activeFocusOnPress: true

                                        Keys.onEscapePressed: {
                                            wifiMenuRoot.expandedSsid = "";
                                            ccRoot.forceActiveFocus();
                                            wifiMenuRoot.updateNetworkList();
                                        }

                                        onAccepted: {
                                            if (passInput.text !== "") {
                                                modelData.networkObj.connect(passInput.text);
                                            } else {
                                                modelData.networkObj.connect();
                                            }
                                            wifiMenuRoot.expandedSsid = "";
                                            ccRoot.forceActiveFocus();
                                            wifiMenuRoot.updateNetworkList();
                                        }
                                    }

                                    Text {
                                        id: eyeBtn
                                        width: 24
                                        anchors.right: parent.right
                                        anchors.rightMargin: 10
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: passCol.showPass ? "󰈈" : "󰈉"
                                        font.family: "SF Pro Display"
                                        font.pixelSize: 16
                                        color: eyeArea.containsMouse ? Colors.aqua : Colors.fg3
                                        horizontalAlignment: Text.AlignRight

                                        MouseArea {
                                            id: eyeArea
                                            anchors.fill: parent
                                            anchors.margins: -5
                                            cursorShape: Qt.PointingHandCursor
                                            hoverEnabled: true
                                            onClicked: {
                                                passCol.showPass = !passCol.showPass;
                                                passInput.forceActiveFocus();
                                            }
                                        }
                                    }
                                }
                                Text {
                                    text: "Press Enter to connect."
                                    font.family: "SF Pro Display"
                                    font.pixelSize: 11
                                    color: Colors.fg3
                                }
                            }

                            // DISCONNECT / FORGET BUTTONS
                            Row {
                                anchors.fill: parent
                                anchors.margins: 12
                                anchors.topMargin: 4
                                spacing: 12
                                visible: modelData.isActive

                                Rectangle {
                                    width: (parent.width - 12) / 2
                                    height: 36
                                    radius: 8
                                    color: connArea.containsMouse ? Colors.bg3 : Colors.bg2
                                    border.color: Colors.bg3
                                    border.width: 1

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 150
                                        }
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        text: "Disconnect"
                                        color: Colors.fg0
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
                                            modelData.networkObj.disconnect();
                                            wifiMenuRoot.expandedSsid = "";
                                            wifiMenuRoot.updateNetworkList();
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
                                            if (modelData.networkObj.forget) {
                                                modelData.networkObj.forget();
                                            } else {
                                                modelData.networkObj.disconnect();
                                            }
                                            wifiMenuRoot.expandedSsid = "";
                                            wifiMenuRoot.updateNetworkList();
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
