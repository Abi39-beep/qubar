import QtQuick
import Quickshell
import Qt5Compat.GraphicalEffects

Item {
    id: powerMenuRoot

    signal closeRequested

    property int selectedIndex: -1
    property int activatedIndex: -1
    property real timeRemaining: 10.0

    // --- THE GLITCH FIX: Delayed Execution ---
    property var pendingCommand: []

    Timer {
        id: executeDelayTimer
        interval: 400 // Gives the pill exactly enough time to finish its closing animation!
        onTriggered: {
            if (powerMenuRoot.pendingCommand.length > 0) {
                Quickshell.execDetached(powerMenuRoot.pendingCommand);
                powerMenuRoot.pendingCommand = [];
            }
        }
    }

    NumberAnimation {
        id: countdownAnim
        target: powerMenuRoot
        property: "timeRemaining"
        from: 10.0
        to: 0.0
        duration: 10000
        onFinished: {
            if (powerMenuRoot.activatedIndex !== -1 && powerMenuRoot.timeRemaining === 0) {
                let cmd = powerMenuRoot.menuItems[powerMenuRoot.activatedIndex].cmd;
                powerMenuRoot.cancelCountdown();
                powerMenuRoot.closeRequested();

                // Triggers the execution delay
                powerMenuRoot.pendingCommand = cmd;
                executeDelayTimer.restart();
            }
        }
    }

    function cancelCountdown() {
        countdownAnim.stop();
        activatedIndex = -1;
        timeRemaining = 10.0;
    }

    onVisibleChanged: {
        if (visible) {
            selectedIndex = -1;
            cancelCountdown();
        } else {
            cancelCountdown();
        }
    }

    property var menuItems: [
        {
            name: "Lock",
            icon: "󰌾",
            color: Colors.green,
            cmd: ["loginctl", "lock-session"]
        },
        {
            name: "Sleep",
            icon: "󰒲",
            color: Colors.blue,
            cmd: ["systemctl", "suspend"]
        },
        {
            name: "Logout",
            icon: "󰍃",
            color: Colors.yellow,
            cmd: ["hyprctl", "dispatch", "hl.dsp.exit()"]
        },
        {
            name: "Reboot",
            icon: "󰜉",
            color: Colors.orange,
            cmd: ["systemctl", "reboot"]
        },
        {
            name: "Shutdown",
            icon: "󰐥",
            color: Colors.red,
            cmd: ["systemctl", "poweroff"]
        }
    ]

    function moveLeft() {
        cancelCountdown();
        if (selectedIndex === -1) {
            selectedIndex = menuItems.length - 1;
        } else {
            selectedIndex = (selectedIndex - 1 + menuItems.length) % menuItems.length;
        }
    }

    function moveRight() {
        cancelCountdown();
        if (selectedIndex === -1) {
            selectedIndex = 0;
        } else {
            selectedIndex = (selectedIndex + 1) % menuItems.length;
        }
    }

    function executeSelected() {
        if (selectedIndex === -1)
            return;

        if (activatedIndex === selectedIndex) {
            let cmd = menuItems[activatedIndex].cmd;
            cancelCountdown();
            closeRequested(); // Closes the widget

            // Triggers the execution delay so the widget can vanish before locking
            powerMenuRoot.pendingCommand = cmd;
            executeDelayTimer.restart();
        } else {
            if (selectedIndex >= 0 && selectedIndex < menuItems.length) {
                cancelCountdown();
                activatedIndex = selectedIndex;
                timeRemaining = 10.0;
                countdownAnim.restart();
            }
        }
    }

    Row {
        anchors.centerIn: parent
        spacing: Config.powerMenuSpacing

        Repeater {
            model: powerMenuRoot.menuItems

            Rectangle {
                width: Config.powerMenuBoxSize
                height: Config.powerMenuBoxSize
                radius: Config.powerMenuBoxRadius

                property bool isSelected: index === powerMenuRoot.selectedIndex
                property bool isActivated: index === powerMenuRoot.activatedIndex

                color: (isSelected && !isActivated) ? modelData.color : Colors.bg2
                border.color: (isSelected && !isActivated) ? modelData.color : Colors.bg3
                border.width: Config.powerMenuBorderWidth

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

                Item {
                    anchors.fill: parent
                    visible: isActivated

                    Rectangle {
                        id: animatedBorder
                        anchors.fill: parent
                        color: "transparent"
                        border.color: modelData.color
                        visible: false

                        radius: Config.powerMenuBoxRadius
                        border.width: Config.powerMenuBorderWidth
                    }

                    ConicalGradient {
                        id: sweepMask
                        anchors.fill: parent
                        angle: -90
                        visible: false
                        gradient: Gradient {
                            GradientStop {
                                position: 0.0
                                color: "white"
                            }
                            GradientStop {
                                position: Math.max(0.0, powerMenuRoot.timeRemaining / 10.0)
                                color: "white"
                            }
                            GradientStop {
                                position: Math.min(1.0, (powerMenuRoot.timeRemaining / 10.0) + 0.001)
                                color: "transparent"
                            }
                            GradientStop {
                                position: 1.0
                                color: "transparent"
                            }
                        }
                    }

                    OpacityMask {
                        anchors.fill: parent
                        source: animatedBorder
                        maskSource: sweepMask
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: isActivated ? Math.ceil(powerMenuRoot.timeRemaining).toString() : modelData.icon
                    color: (isSelected && !isActivated) ? Colors.bg0 : (isActivated ? modelData.color : Colors.fg0)
                    font.family: Config.fontName
                    font.bold: isActivated
                    font.pixelSize: isActivated ? Config.powerMenuCountdownSize : Config.powerMenuIconSize

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }
                }

                MouseArea {
                    id: btnArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onEntered: {
                        if (powerMenuRoot.selectedIndex !== index) {
                            powerMenuRoot.cancelCountdown();
                            powerMenuRoot.selectedIndex = index;
                        }
                    }

                    onClicked: {
                        powerMenuRoot.selectedIndex = index;
                        powerMenuRoot.executeSelected();
                    }
                }
            }
        }
    }
}
