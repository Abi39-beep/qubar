import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.UPower
import "."

Rectangle {
    id: batRoot
    height: 50
    radius: 10
    color: Colors.bg1
    border.width: 1
    border.color: Colors.bg2

    signal closeMainPanel()

    property string activeProfile: ""

    Process {
        id: getProfile
        command:[
            "powerprofilesctl", 
            "get"
        ]
        running: true
        stdout: SplitParser {
            onRead: data => {
                batRoot.activeProfile = data.trim()
            }
        }
    }

    property int batPercent: UPower.displayDevice ? Math.round(UPower.displayDevice.percentage * 100) : 0
    property bool isCharging: !UPower.onBattery

    Row {
        anchors.centerIn: parent
        spacing: 8
        Text {
            text: batRoot.isCharging ? "󰂄" : "󰁹"
            color: batRoot.isCharging ? Colors.green : (batRoot.batPercent <= 20 ? Colors.red : Colors.yellow)
            font.pixelSize: 18
            font.family: "JetBrainsMono Nerd Font"
            anchors.verticalCenter: parent.verticalCenter
        }
        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
            Text { 
                text: "Battery"
                color: Colors.grey1
                font.pixelSize: 10
                font.bold: true 
            }
            Text { 
                text: batRoot.batPercent + "%"
                color: Colors.fg
                font.pixelSize: 12
                font.bold: true 
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            batRoot.closeMainPanel()
            powerPopup.visible = true
            getProfile.running = true
        }
    }

    PanelWindow {
        id: powerPopup
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
                powerPopup.visible = false 
            } 
        }

        Rectangle {
            anchors.centerIn: parent
            width: 320
            height: 220
            color: Qt.alpha(Colors.bg0, 0.98)
            border.color: Colors.bg2
            border.width: 1
            radius: 12
            
            MouseArea { 
                anchors.fill: parent 
            } 
            
            focus: true
            Keys.onEscapePressed: { 
                powerPopup.visible = false 
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
                
                Text { 
                    text: "Power Profile"
                    color: Colors.fg
                    font.bold: true
                    font.pixelSize: 16
                    anchors.horizontalCenter: parent.horizontalCenter 
                }
                
                Rectangle { 
                    width: parent.width
                    height: 1
                    color: Colors.bg2 
                }
                
                Column {
                    width: parent.width
                    spacing: 8
                    
                    Repeater {
                        model:[
                            { name: "Performance ", cmd: "performance" },
                            { name: "Balanced ", cmd: "balanced" },
                            { name: "Power Saver ", cmd: "power-saver" }
                        ]

                        Rectangle {
                            required property var modelData
                            width: parent.width
                            height: 35
                            radius: 6
                            
                            property bool isCurrent: batRoot.activeProfile === modelData.cmd
                            
                            color: isCurrent ? Colors.bg3 : (btnMouse.containsMouse ? Colors.bg2 : "transparent")
                            
                            Behavior on color { 
                                ColorAnimation { 
                                    duration: 150 
                                } 
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                text: parent.isCurrent ? "● " + modelData.name : "  " + modelData.name
                                color: parent.isCurrent ? Colors.green : Colors.fg
                                font.pixelSize: 16
                                font.bold: parent.isCurrent
                                font.family: "JetBrainsMono Nerd Font"
                            }
                            
                            MouseArea {
                                id: btnMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: { 
                                    Quickshell.execDetached([
                                        "powerprofilesctl", 
                                        "set", 
                                        modelData.cmd
                                    ])
                                    batRoot.activeProfile = modelData.cmd
                                    powerPopup.visible = false 
                                } 
                            }
                        }
                    }
                }
            }
        }
    }
}
