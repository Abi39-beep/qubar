import QtQuick
import Quickshell
import Quickshell.Io
import ".."

Rectangle {
    id: btWidget
    width: 20; height: 30
    color: "transparent"
    property bool isBtOn: false
    property bool isScanning: false
    property bool lockUpdates: false 
    Text {
        id: btIcon
        anchors.centerIn: parent
        text: "󰂯"
        font.pixelSize: 18
        font.family: "JetBrainsMono Nerd Font"
        color: btWidget.isBtOn ? Colors.aqua : Colors.grey0
    }
    MouseArea {
        id: btMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            btPopup.visible = !btPopup.visible
            if (btPopup.visible) {
                btWidget.lockUpdates = false;
                refreshBt.running = true
            }
        }
        onContainsMouseChanged: {
            if (containsMouse) {
                btIcon.color = Colors.blue
            } else {
                btIcon.color = btWidget.isBtOn ? Colors.blue : Colors.grey0
            }
        }
    }
    ListModel { id: btModel }
    Timer {
        id: btRefreshDelay
        interval: 3000
        onTriggered: {
            btWidget.lockUpdates = false;
            refreshBt.running = true;
        }
    }
    Process {
        id: refreshBt
        command:["bash", "-c", "bluetoothctl show | grep 'Powered: yes'; echo '---'; bluetoothctl devices Connected; echo '---'; bluetoothctl devices"]
        running: true 
        property string fullOutput: ""
        stdout: SplitParser {
            onRead: data => { refreshBt.fullOutput += data + "\n"; }
        }
        onExited: {
            let sections = fullOutput.split("---\n");
            fullOutput = ""; 
            
            if (sections.length >= 3 && !btWidget.lockUpdates) {
                btWidget.isBtOn = sections[0].includes("Powered: yes");
                
                let connectedLines = sections[1].split("\n");
                let connectedMacs = {};
                for (let i = 0; i < connectedLines.length; i++) {
                    if (connectedLines[i].startsWith("Device ")) {
                        let mac = connectedLines[i].split(" ")[1];
                        connectedMacs[mac] = true;
                    }
                }
                
                btModel.clear();
                let allLines = sections[2].split("\n");
                for (let i = 0; i < allLines.length; i++) {
                    if (allLines[i].startsWith("Device ")) {
                        let parts = allLines[i].split(" ");
                        let mac = parts[1];
                        let name = parts.slice(2).join(" ");
                        let isConn = connectedMacs[mac] === true;
                        btModel.append({ "mac": mac, "name": name, "connected": isConn });
                    }
                }
            }
        }
    }
    Process {
        id: scanBt
        command:["bluetoothctl", "--timeout", "5", "scan", "on"]
        onExited: {
            btWidget.isScanning = false;
            btWidget.lockUpdates = false; 
            refreshBt.running = true;
        }
    }
    PopupWindow {
        id: btPopup
        anchor.item: btWidget
        anchor.edges: Edges.Bottom | Edges.Left
        width: 220; height: 220
        visible: false
        color: "transparent"
        grabFocus: true 
        
        onVisibleChanged: { if (visible) bgRect.forceActiveFocus() }
        Rectangle {
            id: bgRect
            anchors.fill: parent; anchors.topMargin: 10
            color: Qt.alpha(Colors.bg0, 0.95); border.color: Colors.bg2; border.width: 1; radius: 8
            focus: true
            Keys.onEscapePressed: btPopup.visible = false
            onActiveFocusChanged: { if (!activeFocus) btPopup.visible = false }
            Column {
                anchors.fill: parent; anchors.margins: 10; spacing: 10
                Row {
                    spacing: 10
                    width: parent.width
                    
                    Text { 
                        text: "Bluetooth"
                        color: Colors.fg; font.bold: true; font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    Item { width: 35; height: 20 } 
                    
                    Rectangle {
                        width: 40; height: 20; radius: 10
                        color: btWidget.isBtOn ? Colors.blue : Colors.bg2
                        anchors.verticalCenter: parent.verticalCenter
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                btWidget.lockUpdates = true;
                                btWidget.isBtOn = !btWidget.isBtOn;
                                
                                let cmd = btWidget.isBtOn ? "on" : "off";
                                Quickshell.execDetached(["bluetoothctl", "power", cmd]);
                                
                                btRefreshDelay.restart();
                            }
                        }
                        Rectangle {
                            width: 16; height: 16; radius: 8
                            color: Colors.bg0
                            x: btWidget.isBtOn ? 22 : 2
                            anchors.verticalCenter: parent.verticalCenter
                            Behavior on x { NumberAnimation { duration: 150 } }
                        }
                    }
                    Text {
                        text: btWidget.isScanning ? "󰔟" : "󰑐" 
                        color: btWidget.isScanning ? Colors.grey1 : Colors.blue
                        font.pixelSize: 16; font.family: "JetBrainsMono Nerd Font"
                        anchors.verticalCenter: parent.verticalCenter
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            enabled: !btWidget.isScanning 
                            onClicked: {
                                btWidget.lockUpdates = false;
                                btWidget.isScanning = true;
                                scanBt.running = true;
                            }
                        }
                    }
                }
                Rectangle { width: parent.width; height: 1; color: Colors.bg2 } 
                ListView {
                    width: parent.width; height: 230
                    clip: true
                    model: btModel
                    spacing: 6
                    delegate: Rectangle {
                        width: parent.width; height: 35; radius: 6
                        color: model.connected ? Colors.bg2 : "transparent"
                        
                        Text {
                            anchors.left: parent.left; anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            text: model.name
                            color: model.connected ? Colors.blue : Colors.fg
                            font.pixelSize: 12
                            width: 110; elide: Text.ElideRight
                        }
                        
                        Rectangle {
                            anchors.right: parent.right; anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            width: 65; height: 24; radius: 4
                            color: model.connected ? Colors.red : Colors.bg3
                            
                            Text {
                                anchors.centerIn: parent
                                text: model.connected ? "Disconnect" : "Connect"
                                color: Colors.fg; font.pixelSize: 10; font.bold: true
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    btWidget.lockUpdates = true;
                                    btModel.setProperty(index, "connected", !model.connected);
                                    
                                    if (model.connected) { 
                                        Quickshell.execDetached(["bluetoothctl", "connect", model.mac]);
                                    } else {
                                        Quickshell.execDetached(["bluetoothctl", "disconnect", model.mac]);
                                    }
                                    
                                    btRefreshDelay.restart();
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
