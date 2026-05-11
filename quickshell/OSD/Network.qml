import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "."

Item {
    id: netRoot
    width: (parent.width - 15) / 2
    height: 65

    signal closeMainPanel()

    property bool isWifiOn: false
    property bool isWiredNetwork: false
    property string activeSsid: ""

    ListModel { 
        id: wifiModel 
    }

    Process {
        id: refreshNetwork
        command:[
            "bash", 
            "-c", 
            "nmcli -t -f TYPE,STATE dev; echo '---'; nmcli -t -f WIFI radio all; echo '---'; nmcli -t -f ACTIVE,SSID,BSSID dev wifi"
        ]
        property string fullOutput: ""
        stdout: SplitParser { 
            onRead: data => { 
                refreshNetwork.fullOutput += data + "\n" 
            } 
        }
        onExited: {
            let sections = fullOutput.split("---\n")
            fullOutput = ""
            if (sections.length >= 3) {
                netRoot.isWiredNetwork = sections[0].indexOf("ethernet:connected") !== -1 || sections[0].indexOf("wireguard:connected") !== -1
                
                let linesRadio = sections[1].split("\n")
                if (linesRadio.length > 0) {
                    netRoot.isWifiOn = linesRadio[0].trim() === "enabled"
                }
                
                wifiModel.clear()
                netRoot.activeSsid = ""
                let seenSsids = {}
                let linesWifi = sections[2].split("\n")
                
                for (let i = 0; i < linesWifi.length; i++) {
                    let parts = linesWifi[i].split(":")
                    if (parts.length >= 3 && parts[1] && !seenSsids[parts[1]]) {
                        seenSsids[parts[1]] = true
                        let isActive = (parts[0] === "yes")
                        if (isActive) {
                            netRoot.activeSsid = parts[1]
                        }
                        wifiModel.append({ 
                            "active": isActive, 
                            "ssid": parts[1], 
                            "bssid": parts[2], 
                            "expanded": false 
                        })
                    }
                }
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            refreshNetwork.running = true
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: Colors.bg1
        border.color: Colors.bg2
        border.width: 1
        
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: { 
                netRoot.closeMainPanel()
                wifiPopupWindow.visible = true 
                refreshNetwork.running = true
            }
        }
        
        Row {
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 12
            Rectangle {
                width: 40
                height: 40
                radius: 20
                color: netRoot.isWiredNetwork ? Colors.blue : (netRoot.isWifiOn ? Colors.aqua : Colors.bg3)
                Text { 
                    anchors.centerIn: parent
                    text: netRoot.isWiredNetwork ? "󰈀" : (netRoot.isWifiOn ? "󰖩" : "󰖪")
                    color: netRoot.isWifiOn || netRoot.isWiredNetwork ? Colors.bg0 : Colors.fg
                    font.pixelSize: 20
                    font.family: "JetBrainsMono Nerd Font" 
                }
            }
            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4
                Text { 
                    text: netRoot.isWiredNetwork ? "Network" : "Wi-Fi"
                    color: Colors.fg
                    font.bold: true
                    font.pixelSize: 14 
                }
                Text { 
                    text: netRoot.isWiredNetwork ? "Wired" : (netRoot.isWifiOn ? (netRoot.activeSsid || "On") : "Off")
                    color: Colors.grey1
                    font.pixelSize: 11
                    width: 90
                    elide: Text.ElideRight
                }
            }
        }
    }

    PanelWindow {
        id: wifiPopupWindow
        anchors { 
            top: true
            bottom: true
            left: true
            right: true 
        }
        color: "transparent"
        visible: false
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        MouseArea { 
            anchors.fill: parent
            hoverEnabled: true
            onClicked: { 
                wifiPopupWindow.visible = false 
            } 
        }

        Rectangle {
            anchors.centerIn: parent
            width: 320
            height: 400
            color: Qt.alpha(Colors.bg0, 0.98)
            border.color: Colors.bg2
            border.width: 1
            radius: 12
            
            MouseArea { 
                anchors.fill: parent 
            } 
            
            focus: true
            Keys.onEscapePressed: { 
                wifiPopupWindow.visible = false 
            }
            onVisibleChanged: { 
                if (visible) {
                    forceActiveFocus()
                }
            }

            Column {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15
                
                // FIX: Used RowLayout to properly push icons to the right side
                RowLayout {
                    width: parent.width
                    
                    Text { 
                        Layout.fillWidth: true
                        text: "Wi-Fi Networks"
                        color: Colors.fg
                        font.bold: true
                        font.pixelSize: 16
                    }
                    
                    Text { 
                        text: "󰑐"
                        color: Colors.blue
                        font.pixelSize: 16
                        font.family: "JetBrainsMono Nerd Font"
                        
                        MouseArea { 
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: { 
                                refreshNetwork.running = true 
                            } 
                        } 
                    }
                    
                    Rectangle {
                        width: 36
                        height: 18
                        radius: 9
                        color: netRoot.isWifiOn ? Colors.aqua : Colors.bg3
                        
                        Rectangle { 
                            x: netRoot.isWifiOn ? 18 : 2
                            anchors.verticalCenter: parent.verticalCenter
                            width: 14
                            height: 14
                            radius: 7
                            color: Colors.bg0
                            Behavior on x { 
                                NumberAnimation { 
                                    duration: 150 
                                } 
                            } 
                        }
                        
                        MouseArea { 
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: { 
                                netRoot.isWifiOn = !netRoot.isWifiOn
                                Quickshell.execDetached([
                                    "nmcli", 
                                    "radio", 
                                    "wifi", 
                                    netRoot.isWifiOn ? "on" : "off"
                                ]) 
                            } 
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
                    height: 320
                    clip: true
                    spacing: 6
                    model: wifiModel
                    delegate: Rectangle {
                        width: ListView.view ? ListView.view.width : 290
                        height: model.expanded ? 70 : 35
                        radius: 6
                        color: model.active ? Colors.bg2 : "transparent"
                        clip: true
                        Behavior on height { 
                            NumberAnimation { 
                                duration: 150 
                            } 
                        }
                        Item {
                            width: parent.width
                            height: 35
                            Text { 
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                text: model.ssid
                                color: model.active ? Colors.aqua : Colors.fg
                                font.pixelSize: 12
                                width: 150
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
                                            Quickshell.execDetached([
                                                "nmcli", 
                                                "con", 
                                                "down", 
                                                "id", 
                                                model.ssid
                                            ]) 
                                        } else { 
                                            wifiModel.setProperty(index, "expanded", !model.expanded) 
                                        } 
                                    } 
                                }
                            }
                        }
                        Row {
                            y: 35
                            width: parent.width
                            height: 35
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            spacing: 8
                            visible: model.expanded
                            Rectangle { 
                                width: 150
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
                                        if (passInput.text.length > 0) { 
                                            Quickshell.execDetached([
                                                "nmcli", 
                                                "dev", 
                                                "wifi", 
                                                "connect", 
                                                model.bssid, 
                                                "password", 
                                                passInput.text
                                            ]) 
                                        } else { 
                                            Quickshell.execDetached([
                                                "nmcli", 
                                                "dev", 
                                                "wifi", 
                                                "connect", 
                                                model.bssid
                                            ]) 
                                        } 
                                        wifiModel.setProperty(index, "expanded", false)
                                        refreshNetwork.running = true 
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
