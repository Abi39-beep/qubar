import QtQuick
import Quickshell
import Quickshell.Io
import ".."

Rectangle {
    id: wifiWidget
    width: 30
    height: 30
    radius: 15
    color: Colors.bg1
    border.width: 1
    border.color: Colors.bg2

    property bool isWifiOn: false
    property bool isWiredConnected: false // NEW: Tracks Ethernet state

    // NEW LOGIC: Show Wired icon if connected. Otherwise, show Wi-Fi icon based on toggle state.
    Text {
        anchors.centerIn: parent
        text: wifiWidget.isWiredConnected ? "󰈀" : (wifiWidget.isWifiOn ? "󰖩" : "󰖪")
        font.pixelSize: 15
        font.family: "JetBrainsMono Nerd Font"
        color: wifiWidget.isWiredConnected ? Colors.blue : (wifiWidget.isWifiOn ? Colors.blue : Colors.grey0)
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            wifiPopup.visible = !wifiPopup.visible;
            if (wifiPopup.visible)
                refreshNetwork.running = true;
        }
    }

    ListModel {
        id: wifiModel
    }

    Timer {
        id: wifiRefreshDelay
        interval: 1500 // Sped this up so it refreshes faster
        onTriggered: refreshNetwork.running = true
    }

    // Invisibly checks Ethernet AND Wi-Fi states at the same time
    Process {
        id: refreshNetwork
        command: ["bash", "-c", "nmcli -t -f TYPE,STATE dev; echo '---'; nmcli -t -f WIFI radio all; echo '---'; nmcli -t -f ACTIVE,SSID,BSSID dev wifi"]
        running: true
        property string fullOutput: ""
        stdout: SplitParser {
            onRead: data => {
                refreshNetwork.fullOutput += data + "\n";
            }
        }
        onExited: {
            let sections = fullOutput.split("---\n");
            fullOutput = "";

            if (sections.length >= 3) {
                // 1. Check for Wired Connection
                wifiWidget.isWiredConnected = sections[0].includes("ethernet:connected");

                // 2. Check Wi-Fi Radio
                let linesRadio = sections[1].split("\n");
                if (linesRadio.length > 0)
                    wifiWidget.isWifiOn = linesRadio[0].trim() === "enabled";

                // 3. Populate Wi-Fi List
                wifiModel.clear();
                let seenSsids = {};
                let linesWifi = sections[2].split("\n");

                for (let i = 0; i < linesWifi.length; i++) {
                    if (!linesWifi[i])
                        continue;
                    let parts = linesWifi[i].split(":");
                    if (parts.length >= 3) {
                        let active = (parts[0] === "yes");
                        let ssid = parts[1];
                        let bssid = parts[2];

                        if (ssid && !seenSsids[ssid]) {
                            seenSsids[ssid] = true;
                            // Added 'expanded' property to hide/show the password box
                            wifiModel.append({
                                "active": active,
                                "ssid": ssid,
                                "bssid": bssid,
                                "expanded": false
                            });
                        }
                    }
                }
            }
        }
    }

    // --- POPUP WINDOW ---
    PopupWindow {
        id: wifiPopup
        anchor.item: wifiWidget
        anchor.edges: Edges.Bottom | Edges.Left
        width: 220
        height: 220
        visible: false
        color: "transparent"
        grabFocus: true

        onVisibleChanged: {
            if (visible)
                bgRect.forceActiveFocus();
        }

        Rectangle {
            id: bgRect
            anchors.fill: parent
            anchors.topMargin: 10
            color: Qt.alpha(Colors.bg0, 0.95)
            border.color: Colors.bg2
            border.width: 1
            radius: 8
            focus: true
            Keys.onEscapePressed: wifiPopup.visible = false
            onActiveFocusChanged: {
                if (!activeFocus)
                    wifiPopup.visible = false;
            }

            Column {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                Row {
                    spacing: 10
                    width: parent.width

                    Text {
                        text: "Wi-Fi"
                        color: Colors.fg
                        font.bold: true
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Item {
                        width: 60
                        height: 20
                    }

                    Rectangle {
                        width: 40
                        height: 20
                        radius: 10
                        color: wifiWidget.isWifiOn ? Colors.green : Colors.bg2
                        anchors.verticalCenter: parent.verticalCenter
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                // OPTIMISTIC UPDATE: Instantly shift the visual toggle so it feels zero-latency!
                                wifiWidget.isWifiOn = !wifiWidget.isWifiOn;
                                let cmd = wifiWidget.isWifiOn ? "on" : "off";
                                Quickshell.execDetached(["nmcli", "radio", "wifi", cmd]);
                                wifiRefreshDelay.start();
                            }
                        }
                        Rectangle {
                            width: 16
                            height: 16
                            radius: 8
                            color: Colors.bg0
                            x: wifiWidget.isWifiOn ? 22 : 2
                            anchors.verticalCenter: parent.verticalCenter
                            Behavior on x {
                                NumberAnimation {
                                    duration: 150
                                }
                            }
                        }
                    }

                    Text {
                        text: "󰑐"
                        color: Colors.blue
                        font.pixelSize: 16
                        font.family: "JetBrainsMono Nerd Font"
                        anchors.verticalCenter: parent.verticalCenter
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: refreshNetwork.running = true
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Colors.bg2
                }

                ListView {
                    width: parent.width
                    height: 230
                    clip: true
                    model: wifiModel
                    spacing: 6
                    delegate: Rectangle {
                        width: parent.width
                        // NEW: Animates open to make room for the password field!
                        height: model.expanded ? 70 : 35
                        radius: 6
                        color: model.active ? Colors.bg2 : "transparent"
                        clip: true

                        Behavior on height {
                            NumberAnimation {
                                duration: 150
                            }
                        }

                        // Top Row (SSID and Button)
                        Item {
                            width: parent.width
                            height: 35

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                text: model.ssid
                                color: model.active ? Colors.green : Colors.fg
                                font.pixelSize: 12
                                width: 110
                                elide: Text.ElideRight
                            }

                            Rectangle {
                                anchors.right: parent.right
                                anchors.rightMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                width: 65
                                height: 24
                                radius: 4
                                color: model.active ? Colors.red : Colors.bg3

                                Text {
                                    anchors.centerIn: parent
                                    // Button text changes based on the state!
                                    text: model.active ? "Disconnect" : (model.expanded ? "Cancel" : "Connect")
                                    color: Colors.fg
                                    font.pixelSize: 10
                                    font.bold: true
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (model.active) {
                                            wifiModel.setProperty(index, "active", false); // Instant UI feedback!
                                            Quickshell.execDetached(["nmcli", "con", "down", "id", model.ssid]);
                                            wifiRefreshDelay.start();
                                        } else {
                                            // Toggle the password box
                                            wifiModel.setProperty(index, "expanded", !model.expanded);
                                        }
                                    }
                                }
                            }
                        }

                        // NEW: Bottom Row (Password Input) - Only visible when "Connect" is clicked
                        Row {
                            y: 35
                            width: parent.width
                            height: 35
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            spacing: 8
                            visible: model.expanded

                            Rectangle {
                                width: 125
                                height: 24
                                radius: 4
                                color: Colors.bg0
                                border.color: Colors.bg3
                                border.width: 1
                                anchors.verticalCenter: parent.verticalCenter

                                TextInput {
                                    id: passInput
                                    anchors.fill: parent
                                    anchors.margins: 6
                                    color: Colors.fg
                                    font.pixelSize: 11
                                    echoMode: TextInput.Password
                                    clip: true

                                    Text {
                                        text: "Password..."
                                        color: Colors.grey1
                                        font.pixelSize: 11
                                        visible: !passInput.text
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }

                            Rectangle {
                                width: 45
                                height: 24
                                radius: 4
                                color: Colors.blue
                                anchors.verticalCenter: parent.verticalCenter
                                Text {
                                    anchors.centerIn: parent
                                    text: "Go"
                                    color: Colors.bg0
                                    font.bold: true
                                    font.pixelSize: 11
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        // If password is typed, use it. If left completely blank, try connecting without one (for saved networks)
                                        if (passInput.text.length > 0) {
                                            Quickshell.execDetached(["nmcli", "dev", "wifi", "connect", model.bssid, "password", passInput.text]);
                                        } else {
                                            Quickshell.execDetached(["nmcli", "dev", "wifi", "connect", model.bssid]);
                                        }
                                        wifiModel.setProperty(index, "expanded", false);
                                        wifiRefreshDelay.start();
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
