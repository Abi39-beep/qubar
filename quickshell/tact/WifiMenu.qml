import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: wifiMenuRoot
    signal backRequested

    property string targetSsid: ""
    property bool targetIsActive: false

    // THE FIX: Safe parser for Network Names!
    Process {
        id: scanProc
        command: ["bash", "-c", "nmcli -t -f ACTIVE,SIGNAL,SSID dev wifi list"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                networkModel.clear();
                let lines = data.split("\n");
                let seenSsids = {};

                for (let i = 0; i < lines.length; i++) {
                    let line = lines[i].trim();
                    if (!line)
                        continue;

                    let firstColon = line.indexOf(":");
                    let secondColon = line.indexOf(":", firstColon + 1);

                    if (firstColon > -1 && secondColon > -1) {
                        let activeStr = line.substring(0, firstColon);
                        let isActive = (activeStr === "yes" || activeStr === "*");
                        let signal = parseInt(line.substring(firstColon + 1, secondColon)) || 0;
                        let ssid = line.substring(secondColon + 1);

                        if (ssid !== "" && !seenSsids[ssid]) {
                            seenSsids[ssid] = true;
                            networkModel.append({
                                "ssid": ssid,
                                "signal": signal,
                                "isActive": isActive
                            });
                        }
                    }
                }
            }
        }
    }

    ListModel {
        id: networkModel
    }

    // Dynamic Fading for the List Icons
    function getWifiOpacity(sig) {
        if (sig > 75)
            return 1.0;
        if (sig > 50)
            return 0.65;
        if (sig > 25)
            return 0.35;
        return 0.15;
    }

    Column {
        anchors.fill: parent
        spacing: 16

        // --- HEADER ---
        Row {
            width: parent.width
            spacing: 16
            MouseArea {
                width: 32
                height: 32
                cursorShape: Qt.PointingHandCursor
                onClicked: wifiMenuRoot.backRequested()
                Text {
                    anchors.centerIn: parent
                    text: "󰁍"
                    font.family: Config.fontName
                    font.pixelSize: 20
                    color: Colors.fg0
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

            Column {
                id: listCol
                width: parent.width
                spacing: 8

                Repeater {
                    model: networkModel
                    Rectangle {
                        width: parent.width
                        height: 48
                        radius: 12
                        color: model.isActive ? Colors.bg2 : Colors.bg1
                        border.color: model.isActive ? Colors.aqua : Colors.bg2
                        border.width: 1

                        Row {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 16
                            spacing: 12

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: "" // YOUR EXACT SOLID WEDGE
                                font.family: Config.fontName
                                font.pixelSize: 18
                                color: model.isActive ? Colors.aqua : Colors.fg0
                                opacity: wifiMenuRoot.getWifiOpacity(model.signal)
                            }
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: model.ssid // Device name fixed!
                                font.family: Config.fontName
                                font.pixelSize: 14
                                font.bold: model.isActive
                                color: model.isActive ? Colors.aqua : Colors.fg0
                                width: parent.width - 140
                                elide: Text.ElideRight
                            }
                        }

                        Text {
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

                        // CLICK LOGIC: Opens the Action Prompt!
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                wifiMenuRoot.targetSsid = model.ssid;
                                wifiMenuRoot.targetIsActive = model.isActive;
                                actionPrompt.visible = true;
                                if (!model.isActive)
                                    passInput.forceActiveFocus();
                            }
                        }
                    }
                }
            }
        }

        // --- THE ACTION PROMPT (Connect / Disconnect / Forget) ---
        Rectangle {
            id: actionPrompt
            anchors.fill: parent
            color: Colors.bg0
            radius: 16
            visible: false
            z: 10

            Column {
                anchors.centerIn: parent
                spacing: 16
                width: parent.width - 40

                Text {
                    text: wifiMenuRoot.targetIsActive ? "Manage " + wifiMenuRoot.targetSsid : "Connect to " + wifiMenuRoot.targetSsid
                    font.family: Config.fontName
                    font.pixelSize: 14
                    font.bold: true
                    color: Colors.fg0
                    width: parent.width
                    elide: Text.ElideRight
                }

                // UI 1: PASSWORD BOX (If Not Connected)
                Column {
                    width: parent.width
                    spacing: 12
                    visible: !wifiMenuRoot.targetIsActive

                    Rectangle {
                        width: parent.width
                        height: 40
                        radius: 8
                        color: Colors.bg1
                        border.color: Colors.aqua
                        border.width: 1

                        TextInput {
                            id: passInput
                            anchors.fill: parent
                            anchors.margins: 10
                            color: Colors.fg0
                            font.family: Config.fontName
                            font.pixelSize: 14
                            echoMode: TextInput.Password
                            clip: true

                            Keys.onEscapePressed: {
                                actionPrompt.visible = false;
                                ccRoot.forceActiveFocus();
                            }
                            onAccepted: {
                                Qt.createQmlObject('import Quickshell.Io; Process { command: ["bash", "-c", "nmcli dev wifi connect \'' + wifiMenuRoot.targetSsid + '\' password \'' + passInput.text + '\'"]; running: true }', wifiMenuRoot, "connectProc");
                                actionPrompt.visible = false;
                                ccRoot.forceActiveFocus();
                                scanProc.running = false;
                                scanProc.running = true; // Refresh list
                            }
                        }
                    }
                    Text {
                        text: "Press Enter to connect. Esc to cancel."
                        font.family: Config.fontName
                        font.pixelSize: 11
                        color: Colors.fg3
                    }
                }

                // UI 2: DISCONNECT & FORGET BUTTONS (If you click a Connected Network!)
                Row {
                    width: parent.width
                    spacing: 12
                    visible: wifiMenuRoot.targetIsActive

                    // The Disconnect Button
                    Rectangle {
                        width: (parent.width - 12) / 2
                        height: 40
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
                            onClicked: {
                                Qt.createQmlObject('import Quickshell.Io; Process { command: ["bash", "-c", "nmcli con down id \'' + wifiMenuRoot.targetSsid + '\'"]; running: true }', wifiMenuRoot, "discProc");
                                actionPrompt.visible = false;
                                scanProc.running = false;
                                scanProc.running = true;
                            }
                        }
                    }

                    // The Forget Button
                    Rectangle {
                        width: (parent.width - 12) / 2
                        height: 40
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
                            onClicked: {
                                Qt.createQmlObject('import Quickshell.Io; Process { command: ["bash", "-c", "nmcli con delete id \'' + wifiMenuRoot.targetSsid + '\'"]; running: true }', wifiMenuRoot, "forgetProc");
                                actionPrompt.visible = false;
                                scanProc.running = false;
                                scanProc.running = true;
                            }
                        }
                    }
                }
            }
            Keys.onEscapePressed: {
                actionPrompt.visible = false;
                ccRoot.forceActiveFocus();
            }
        }
    }
}
