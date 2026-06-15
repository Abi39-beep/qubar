import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: wifiMenuRoot
    signal backRequested

    property var knownNetworks: []
    property string expandedSsid: ""

    onVisibleChanged: {
        if (!visible)
            expandedSsid = "";
    }

    // --- THE FIX: DEDICATED BACKGROUND PROCESSER ---
    // This safely runs your connect/disconnect commands and WAITS for them to finish before refreshing the UI.
    Process {
        id: actionProc
        running: false
        onExited: {
            scanProc.running = false;
            scanProc.running = true; // Refreshes the list ONLY after nmcli finishes!
        }
    }

    Process {
        id: scanProc
        command: ["bash", "-c", "nmcli -t -f ACTIVE,SIGNAL,SSID dev wifi list"]
        running: true

        onRunningChanged: {
            if (running) {
                networkModel.clear();
                wifiMenuRoot.knownNetworks = [];
            }
        }

        stdout: SplitParser {
            onRead: data => {
                let lines = data.split("\n");
                let currentKnown = wifiMenuRoot.knownNetworks;

                for (let i = 0; i < lines.length; i++) {
                    let line = lines[i].trim();
                    if (!line)
                        continue;

                    let parts = line.split(":");
                    if (parts.length >= 3) {
                        let isActive = (parts[0] === "yes" || parts[0] === "*");
                        let signal = parseInt(parts[1]) || 0;
                        let ssid = parts.slice(2).join(":");

                        if (ssid !== "" && currentKnown.indexOf(ssid) === -1) {
                            currentKnown.push(ssid);
                            networkModel.append({
                                "ssid": ssid,
                                "signal": signal,
                                "isActive": isActive
                            });
                        }
                    }
                }
                wifiMenuRoot.knownNetworks = currentKnown;
            }
        }
    }

    ListModel {
        id: networkModel
    }

    Column {
        anchors.fill: parent
        spacing: 16

        // --- HEADER WITH CIRCULAR BACK BUTTON ---
        Row {
            width: parent.width
            spacing: 12

            Rectangle {
                width: 36
                height: 36
                radius: 18
                color: backArea.containsMouse ? Colors.bg2 : Colors.bg1
                border.color: Colors.bg2
                border.width: 1

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
                    onClicked: wifiMenuRoot.backRequested()
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "Wi-Fi Networks"
                font.family: Config.fontName
                font.pixelSize: 16
                font.bold: true
                color: Colors.fg0
            }
        }

        // --- NETWORK LIST ---
        Flickable {
            width: parent.width
            height: parent.height - 50
            contentHeight: listCol.implicitHeight
            clip: true
            interactive: true

            Column {
                id: listCol
                width: parent.width
                spacing: 8

                Repeater {
                    model: networkModel
                    Rectangle {
                        id: networkBox
                        width: parent.width
                        property bool isExpanded: wifiMenuRoot.expandedSsid === model.ssid

                        height: isExpanded ? (model.isActive ? 104 : 124) : 48
                        radius: 12
                        clip: true

                        color: model.isActive ? Colors.bg2 : (netMouseArea.containsMouse ? Colors.bg2 : Colors.bg1)
                        border.color: model.isActive ? Colors.aqua : (netMouseArea.containsMouse ? Colors.bg3 : Colors.bg2)
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

                        // =========================================
                        // 1. TOP ROW (Name & Badge)
                        // =========================================
                        Item {
                            width: parent.width
                            height: 48

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 16
                                anchors.right: statusBadge.visible ? statusBadge.left : parent.right
                                anchors.rightMargin: 16
                                text: model.ssid
                                font.family: Config.fontName
                                font.pixelSize: 14
                                font.bold: model.isActive
                                color: model.isActive ? Colors.aqua : Colors.fg0
                                elide: Text.ElideRight
                            }

                            Text {
                                id: statusBadge
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                anchors.rightMargin: 16
                                visible: model.isActive
                                text: "Connected"
                                color: Colors.aqua
                                font.family: Config.fontName
                                font.pixelSize: 12
                                font.bold: true
                            }

                            MouseArea {
                                id: netMouseArea
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onClicked: {
                                    if (wifiMenuRoot.expandedSsid === model.ssid) {
                                        wifiMenuRoot.expandedSsid = "";
                                    } else {
                                        wifiMenuRoot.expandedSsid = model.ssid;
                                        if (!model.isActive)
                                            passInput.forceActiveFocus();
                                    }
                                }
                            }
                        }

                        // =========================================
                        // 2. EXPANDED CONTENT AREA
                        // =========================================
                        Item {
                            y: 48
                            width: parent.width
                            height: parent.height - 48
                            opacity: networkBox.isExpanded ? 1 : 0
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 250
                                }
                            }

                            // A. PASSWORD BOX
                            Column {
                                anchors.fill: parent
                                anchors.margins: 12
                                anchors.topMargin: 0
                                spacing: 8
                                visible: !model.isActive

                                property bool showPass: false

                                Rectangle {
                                    width: parent.width
                                    height: 36
                                    radius: 8
                                    color: Colors.bg0
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
                                        font.family: Config.fontName
                                        font.pixelSize: 14
                                        echoMode: parent.parent.showPass ? TextInput.Normal : TextInput.Password
                                        clip: true

                                        Keys.onEscapePressed: {
                                            wifiMenuRoot.expandedSsid = "";
                                            ccRoot.forceActiveFocus();
                                        }

                                        // THE FIX: Uses actionProc so it waits for Linux to finish connecting!
                                        onAccepted: {
                                            actionProc.command = ["bash", "-c", "nmcli dev wifi connect '" + model.ssid + "' password '" + passInput.text + "'"];
                                            actionProc.running = true;
                                            wifiMenuRoot.expandedSsid = "";
                                            ccRoot.forceActiveFocus();
                                        }
                                    }

                                    Text {
                                        id: eyeBtn
                                        anchors.right: parent.right
                                        anchors.rightMargin: 10
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: parent.parent.showPass ? "󰈈" : "󰈉"
                                        font.family: Config.fontName
                                        font.pixelSize: 16
                                        color: Colors.fg3

                                        MouseArea {
                                            anchors.fill: parent
                                            anchors.margins: -5
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                parent.parent.parent.showPass = !parent.parent.parent.showPass;
                                                passInput.forceActiveFocus();
                                            }
                                        }
                                    }
                                }
                                Text {
                                    text: "Press Enter to connect."
                                    font.family: Config.fontName
                                    font.pixelSize: 11
                                    color: Colors.fg3
                                }
                            }

                            // B. DISCONNECT / FORGET BUTTONS
                            Row {
                                anchors.fill: parent
                                anchors.margins: 12
                                anchors.topMargin: 4
                                spacing: 12
                                visible: model.isActive

                                Rectangle {
                                    width: (parent.width - 12) / 2
                                    height: 36
                                    radius: 8
                                    color: Colors.bg2
                                    Text {
                                        anchors.centerIn: parent
                                        text: "Disconnect"
                                        color: Colors.fg0
                                        font.family: Config.fontName
                                        font.pixelSize: 13
                                        font.bold: true
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor

                                        // THE FIX: Uses actionProc so it waits to disconnect before refreshing!
                                        onClicked: {
                                            actionProc.command = ["bash", "-c", "nmcli con down id '" + model.ssid + "'"];
                                            actionProc.running = true;
                                            wifiMenuRoot.expandedSsid = "";
                                        }
                                    }
                                }
                                Rectangle {
                                    width: (parent.width - 12) / 2
                                    height: 36
                                    radius: 8
                                    color: Colors.red
                                    Text {
                                        anchors.centerIn: parent
                                        text: "Forget"
                                        color: Colors.bg0
                                        font.family: Config.fontName
                                        font.pixelSize: 13
                                        font.bold: true
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor

                                        // THE FIX: Uses actionProc so it waits to forget before refreshing!
                                        onClicked: {
                                            actionProc.command = ["bash", "-c", "nmcli con delete id '" + model.ssid + "'"];
                                            actionProc.running = true;
                                            wifiMenuRoot.expandedSsid = "";
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
