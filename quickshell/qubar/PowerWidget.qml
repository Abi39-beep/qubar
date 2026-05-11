import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland 
import "."

Rectangle {
    id: powerWidgetWidget
    width: 30; height: 30; radius: 15
    color: Colors.bg1 
    border.width: 1
    border.color: Colors.bg2

    // This listens for the keyboard shortcut from Hyprland!
    GlobalShortcut {
        name: "powermenu" 
        onPressed: {
            if (!powerMenuWindow.visible) {
                powerMenuWindow.visible = true
                bgDimmer.forceActiveFocus() 
                powerList.forceActiveFocus() 
            } else {
                powerMenuWindow.closeMenu()
            }
        }
    }

    Text {
        anchors.centerIn: parent
        text: "" 
        font.pixelSize: 15
        font.family: "JetBrainsMono Nerd Font"
        color: Colors.red 
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            powerMenuWindow.visible = true
            bgDimmer.forceActiveFocus()
            powerList.forceActiveFocus()
        }
    }

    Process {
        id: executor
        property string currentCommand: ""
        command:["bash", "-c", currentCommand]
    }

    PanelWindow {
        id: powerMenuWindow
        
        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        
        WlrLayershell.layer: WlrLayer.Overlay 
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        
        visible: false
        
        property int activeIndex: -1
        property int countdown: 10
        
        function closeMenu() {
            visible = false
            activeIndex = -1
            countdownTimer.stop()
        }
        
        function executeAction(cmd) {
            countdownTimer.stop()
            executor.currentCommand = cmd
            executor.running = true
            closeMenu()
        }

        function handleTrigger(index, cmd) {
            if (activeIndex === index) {
                executeAction(cmd)
            } else {
                activeIndex = index
                countdown = 10
                countdownTimer.restart()
            }
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
        
        property var actionModel:[
            { name: "Lock", icon: "", cmd: "$HOME/.config/hypr/hyprlock.sh" },
            { name: "Sleep", icon: "󰤄", cmd: "systemctl suspend" },
            { name: "Logout", icon: "󰍃", cmd: "hyprctl dispatch exit" },
            { name: "Power", icon: "", cmd: "systemctl poweroff" }
        ]

        Rectangle {
            id: bgDimmer
            anchors.fill: parent
            color: "#CC000000" 
            
            focus: true
            Keys.onEscapePressed: powerMenuWindow.closeMenu()

            MouseArea {
                anchors.fill: parent
                onClicked: powerMenuWindow.closeMenu()
            }

            ListView {
                id: powerList
                anchors.centerIn: parent
                width: (120 * 4) + (20 * 3) 
                height: 120
                orientation: ListView.Horizontal
                spacing: 20
                focus: true
                
                Keys.onEscapePressed: powerMenuWindow.closeMenu()
                Keys.onLeftPressed: currentIndex = Math.max(0, currentIndex - 1)
                Keys.onRightPressed: currentIndex = Math.min(count - 1, currentIndex + 1)
                
                Keys.onReturnPressed: {
                    let currentItem = powerMenuWindow.actionModel[currentIndex]
                    powerMenuWindow.handleTrigger(currentIndex, currentItem.cmd)
                }

                model: powerMenuWindow.actionModel

                delegate: Rectangle {
                    id: btnRect
                    width: 120; height: 120; radius: 16
                    color: Colors.bg0
                    
                    property bool isActive: powerMenuWindow.activeIndex === index
                    property bool isFocused: powerList.currentIndex === index && powerList.activeFocus
                    
                    border.width: isActive ? 2 : (isFocused ? 1 : 1)
                    border.color: isActive ? Colors.red : (isFocused ? Colors.blue : Colors.bg2)

                    Column {
                        anchors.centerIn: parent
                        spacing: 12

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: btnRect.isActive ? powerMenuWindow.countdown : modelData.icon
                            font.pixelSize: 40
                            font.family: "JetBrainsMono Nerd Font"
                            color: btnRect.isActive ? Colors.red : Colors.fg
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: btnRect.isActive ? "Confirm?" : modelData.name
                            font.pixelSize: 14
                            font.bold: true
                            color: Colors.fg
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        
                        onEntered: { powerList.currentIndex = index }
                        
                        onClicked: {
                            powerList.currentIndex = index
                            powerList.forceActiveFocus()
                            powerMenuWindow.handleTrigger(index, modelData.cmd)
                        }
                    }
                }
            }
            
            Text {
                anchors.top: powerList.bottom
                anchors.topMargin: 40
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Click once or press Enter to start 10s timer. Double click to execute instantly.\nPress Esc or click outside to cancel."
                horizontalAlignment: Text.AlignHCenter
                color: Colors.grey1
                font.pixelSize: 12
            }
        }
    }
}
