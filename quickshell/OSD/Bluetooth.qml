import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import "."

Item {
    id: btRoot
    width: (parent.width - 15) / 2
    height: 65

    signal closeMainPanel()

    property bool isBtOn: false
    property string activeBtDevice: ""

    PwObjectTracker { 
        id: rightPwTracker
        objects: Pipewire.defaultAudioSink ?[Pipewire.defaultAudioSink] :[] 
    }
    
    property var rightAudio: Pipewire.defaultAudioSink
    property string desc: rightAudio ? rightAudio.description : ""
    property bool isWiredHeadset: desc.toLowerCase().indexOf("analog") !== -1 || desc.toLowerCase().indexOf("headset") !== -1 || desc.toLowerCase().indexOf("headphone") !== -1

    ListModel { 
        id: btModel 
    }
    
    Process {
        id: refreshBt
        command:[
            "bash", 
            "-c", 
            "bluetoothctl show | grep 'Powered: yes'; echo '---'; bluetoothctl devices Connected; echo '---'; bluetoothctl devices"
        ]
        property string fullOutput: ""
        stdout: SplitParser { 
            onRead: data => { 
                refreshBt.fullOutput += data + "\n" 
            } 
        }
        onExited: {
            let sections = fullOutput.split("---\n")
            fullOutput = ""
            if (sections.length >= 3) {
                btRoot.isBtOn = sections[0].indexOf("Powered: yes") !== -1
                
                let connectedMacs = {}
                let connectedLines = sections[1].split("\n")
                btRoot.activeBtDevice = ""
                
                for (let i = 0; i < connectedLines.length; i++) { 
                    if (connectedLines[i].startsWith("Device ")) {
                        let parts = connectedLines[i].split(" ")
                        connectedMacs[parts[1]] = true
                        btRoot.activeBtDevice = parts.slice(2).join(" ")
                    }
                }
                
                btModel.clear()
                let allLines = sections[2].split("\n")
                
                for (let i = 0; i < allLines.length; i++) {
                    if (allLines[i].startsWith("Device ")) {
                        let parts = allLines[i].split(" ")
                        let mac = parts[1]
                        let name = parts.slice(2).join(" ")
                        btModel.append({ 
                            "mac": mac, 
                            "name": name, 
                            "connected": (connectedMacs[mac] === true) 
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
            refreshBt.running = true
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
                btRoot.closeMainPanel()
                btPopupWindow.visible = true 
                refreshBt.running = true
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
                color: btRoot.isWiredHeadset ? Colors.blue : (btRoot.isBtOn ? Colors.aqua : Colors.bg3)
                Text { 
                    anchors.centerIn: parent
                    text: btRoot.isWiredHeadset ? "󰋋" : (btRoot.isBtOn ? "󰂯" : "󰂲")
                    color: btRoot.isBtOn || btRoot.isWiredHeadset ? Colors.bg0 : Colors.fg
                    font.pixelSize: 20
                    font.family: "JetBrainsMono Nerd Font" 
                }
            }
            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4
                Text { 
                    text: "Bluetooth"
                    color: Colors.fg
                    font.bold: true
                    font.pixelSize: 14 
                }
                Text { 
                    text: btRoot.isWiredHeadset ? "Wired Headset" : (btRoot.isBtOn ? (btRoot.activeBtDevice || "On") : "Off")
                    color: Colors.grey1
                    font.pixelSize: 11
                    width: 90
                    elide: Text.ElideRight
                }
            }
        }
    }

    PanelWindow {
        id: btPopupWindow
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
                btPopupWindow.visible = false 
            } 
        }

        Rectangle {
            anchors.centerIn: parent
            width: 320
            height: 200
            color: Qt.alpha(Colors.bg0, 0.98)
            border.color: Colors.bg2
            border.width: 1
            radius: 12
            
            MouseArea { 
                anchors.fill: parent 
            }
            
            focus: true
            Keys.onEscapePressed: { 
                btPopupWindow.visible = false 
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
                        text: "Bluetooth Devices"
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
                                refreshBt.running = true 
                            } 
                        } 
                    }
                    
                    Rectangle {
                        width: 36
                        height: 18
                        radius: 9
                        color: btRoot.isBtOn ? Colors.aqua : Colors.bg3
                        Rectangle { 
                            x: btRoot.isBtOn ? 18 : 2
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
                                btRoot.isBtOn = !btRoot.isBtOn
                                Quickshell.execDetached([
                                    "bluetoothctl", 
                                    "power", 
                                    btRoot.isBtOn ? "on" : "off"
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
                    model: btModel
                    delegate: Rectangle {
                        width: ListView.view ? ListView.view.width : 290
                        height: 35
                        radius: 6
                        color: model.connected ? Colors.bg2 : "transparent"
                        Text { 
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            text: model.name
                            color: model.connected ? Colors.aqua : Colors.fg
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
                            color: model.connected ? Colors.red : Colors.bg3
                            Text { 
                                anchors.centerIn: parent
                                text: model.connected ? "Disconnect" : "Connect"
                                color: Colors.fg
                                font.pixelSize: 10
                                font.bold: true 
                            }
                            MouseArea { 
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: { 
                                    Quickshell.execDetached([
                                        "bluetoothctl", 
                                        model.connected ? "disconnect" : "connect", 
                                        model.mac
                                    ]) 
                                } 
                            }
                        }
                    }
                }
            }
        }
    }
}
