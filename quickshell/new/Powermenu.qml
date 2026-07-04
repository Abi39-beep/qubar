pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Qt5Compat.GraphicalEffects

Item {
    id: powerMenuRoot
    height: 60

    signal closeRequested
    signal closePanel

    property int selectedIndex: -1
    property int activatedIndex: -1
    property real timeRemaining: 10.0
    property var pendingCommand: []

    // KEYBOARD NAVIGATION LOGIC
    onVisibleChanged: {
        if (visible) {
            selectedIndex = -1;
            cancelCountdown();
            forceActiveFocus();
        } else {
            cancelCountdown();
        }
    }

    Keys.onLeftPressed: moveLeft()
    Keys.onRightPressed: moveRight()
    Keys.onReturnPressed: executeSelected()
    Keys.onEnterPressed: executeSelected()
    Keys.onEscapePressed: {
        cancelCountdown();
        closeRequested();
    }

    // EXECUTION LOGIC
    Timer {
        id: executeDelayTimer
        interval: 800
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
            if (powerMenuRoot.activatedIndex !== -1 && powerMenuRoot.timeRemaining <= 0.05) {
                let cmd = powerMenuRoot.menuItems[powerMenuRoot.activatedIndex].cmd;
                powerMenuRoot.cancelCountdown();

                powerMenuRoot.closeRequested();
                powerMenuRoot.closePanel();

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

            powerMenuRoot.closeRequested();
            powerMenuRoot.closePanel();

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

    // UI: BUTTON ROW
    Row {
        anchors.centerIn: parent
        spacing: 12

        Repeater {
            model: powerMenuRoot.menuItems

            Rectangle {
                id: delegateRect

                required property int index
                required property var modelData

                width: 60
                height: 60
                radius: 16

                property bool isSelected: index === powerMenuRoot.selectedIndex
                property bool isActivated: index === powerMenuRoot.activatedIndex

                color: (isSelected && !isActivated) ? modelData.color : Colors.bg2
                border.color: (isSelected && !isActivated) ? modelData.color : Colors.bg3
                border.width: 2

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
                    visible: delegateRect.isActivated

                    Rectangle {
                        id: animatedBorder
                        anchors.fill: parent
                        color: "transparent"
                        border.color: delegateRect.modelData.color
                        visible: false
                        radius: 16
                        border.width: 2
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
                    text: delegateRect.isActivated ? Math.ceil(powerMenuRoot.timeRemaining).toString() : delegateRect.modelData.icon
                    color: (delegateRect.isSelected && !delegateRect.isActivated) ? Colors.bg0 : (delegateRect.isActivated ? delegateRect.modelData.color : Colors.fg0)
                    font.family: delegateRect.isActivated ? "SF Pro Display" : "JetBrainsMono Nerd Font"
                    font.bold: delegateRect.isActivated
                    font.pixelSize: delegateRect.isActivated ? 24 : 22

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
                        if (powerMenuRoot.selectedIndex !== delegateRect.index) {
                            powerMenuRoot.cancelCountdown();
                            powerMenuRoot.selectedIndex = delegateRect.index;
                        }
                    }

                    onClicked: {
                        powerMenuRoot.selectedIndex = delegateRect.index;
                        powerMenuRoot.executeSelected();
                    }
                }
            }
        }
    }
}
