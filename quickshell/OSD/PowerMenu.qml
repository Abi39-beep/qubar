import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "."

PanelWindow {
    id: powerMenuWindow
    
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
    
    property int activeIndex: -1
    property int countdown: 10
    
    property var actionModel:[
        { 
            name: "Lock", 
            icon: "", 
            cmd: "loginctl lock-session", 
            color: Colors.blue 
        },
        { 
            name: "Sleep", 
            icon: "󰤄", 
            cmd: "systemctl suspend", 
            color: Colors.blue 
        },
        { 
            name: "Logout", 
            icon: "󰍃", 
            // FIX: Restored Hyprland 0.55.0 Lua dispatcher format!
            cmd: "hyprctl dispatch 'hl.dsp.exit()'", 
            color: Colors.orange 
        },
        { 
            name: "Reboot", 
            icon: "", 
            cmd: "systemctl reboot", 
            color: Colors.orange 
        },
        { 
            name: "Power", 
            icon: "", 
            cmd: "systemctl poweroff", 
            color: Colors.red 
        }
    ]

    Process { 
        id: executor
        property string currentCommand: ""
        command:[
            "bash", 
            "-c", 
            currentCommand
        ] 
    }

    function closeMenu() { 
        powerMenuWindow.visible = false
        powerMenuWindow.activeIndex = -1
        countdownTimer.stop() 
    }
    
    function executeAction(cmd) { 
        countdownTimer.stop()
        executor.currentCommand = cmd
        executor.running = true
        closeMenu() 
    }
    
    function handleTrigger(index, cmd) { 
        if (powerMenuWindow.activeIndex === index) { 
            executeAction(cmd) 
        } else { 
            powerMenuWindow.activeIndex = index
            powerMenuWindow.countdown = 10
            countdownTimer.restart() 
        } 
    }
    
    function openMenu(index = -1) {
        powerMenuWindow.visible = true
        powerMenuWindow.activeIndex = index
        if (index !== -1) {
            powerMenuWindow.countdown = 10
            countdownTimer.restart()
        }
        powerList.forceActiveFocus()
    }

    Timer {
        id: countdownTimer
        interval: 1000
        repeat: true
        onTriggered: { 
            powerMenuWindow.countdown--
            if (powerMenuWindow.countdown <= 0) { 
                let cmd = powerMenuWindow.actionModel[powerMenuWindow.activeIndex].cmd
                powerMenuWindow.executeAction(cmd) 
            } 
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#CC000000"
        
        MouseArea { 
            anchors.fill: parent
            hoverEnabled: true 
            onClicked: { 
                powerMenuWindow.closeMenu() 
            } 
        }
        
        focus: true
        Keys.onEscapePressed: { 
            powerMenuWindow.closeMenu() 
        }
        
        onVisibleChanged: { 
            if (visible) {
                powerMenuWindow.forceActiveFocus()
                powerList.forceActiveFocus()
            }
        }

        Column {
            anchors.centerIn: parent
            spacing: 40
            
            ListView {
                id: powerList
                width: (100 * 5) + (20 * 4)
                height: 100
                orientation: ListView.Horizontal
                spacing: 20
                
                focus: true
                keyNavigationEnabled: true
                
                Keys.onEscapePressed: { 
                    powerMenuWindow.closeMenu() 
                }
                Keys.onLeftPressed: { 
                    currentIndex = Math.max(0, currentIndex - 1) 
                }
                Keys.onRightPressed: { 
                    currentIndex = Math.min(count - 1, currentIndex + 1) 
                }
                Keys.onReturnPressed: { 
                    let currentItem = powerMenuWindow.actionModel[currentIndex]
                    powerMenuWindow.handleTrigger(currentIndex, currentItem.cmd) 
                }
                
                model: powerMenuWindow.actionModel
                
                delegate: Rectangle {
                    id: btnRect
                    width: 100
                    height: 100
                    radius: 16
                    color: Colors.bg1
                    
                    property bool isActive: powerMenuWindow.activeIndex === index
                    property bool isFocused: powerList.currentIndex === index && powerList.activeFocus
                    
                    border.width: isActive ? 2 : (isFocused ? 2 : 1)
                    border.color: isActive ? Colors.red : (isFocused ? Colors.aqua : Colors.bg2)
                    
                    scale: fullPowerMouse.containsMouse || isFocused ? 1.05 : 1.0
                    
                    Behavior on scale { 
                        NumberAnimation { 
                            duration: 150
                            easing.type: Easing.OutBack 
                        } 
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: 12
                        Text { 
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: btnRect.isActive ? powerMenuWindow.countdown : modelData.icon
                            font.pixelSize: 32
                            font.family: "JetBrainsMono Nerd Font"
                            color: btnRect.isActive ? Colors.red : modelData.color 
                        }
                        Text { 
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: btnRect.isActive ? "Confirm?" : modelData.name
                            font.pixelSize: 12
                            font.bold: true
                            color: Colors.fg 
                        }
                    }
                    
                    MouseArea {
                        id: fullPowerMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: { 
                            powerList.currentIndex = index 
                        }
                        onClicked: { 
                            powerList.currentIndex = index
                            powerList.forceActiveFocus()
                            powerMenuWindow.handleTrigger(index, modelData.cmd) 
                        }
                    }
                }
            }
            
            Text { 
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Click once or press Enter to start 10s timer."
                color: Colors.grey1
                font.pixelSize: 12 
            }
        }
    }
}
