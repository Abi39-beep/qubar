pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import ".."

Item {
    id: barRoot
    height: 224
    signal closeMenu

    property string activeBar: ""
    property int currentIndex: -1

    onVisibleChanged: {
        if (visible) {
            forceActiveFocus();
            getActiveProc.running = true;
            currentIndex = -1;
            flickView.contentY = 0;
        }
    }

    // --- KEYBOARD NAVIGATION ---
    Keys.onEscapePressed: barRoot.closeMenu()
    Keys.onUpPressed: {
        if (barModel.count > 0) {
            if (currentIndex === -1)
                currentIndex = barModel.count - 1;
            else
                currentIndex = (currentIndex + barModel.count - 1) % barModel.count;
            ensureVisible();
        }
    }
    Keys.onDownPressed: {
        if (barModel.count > 0) {
            if (currentIndex === -1)
                currentIndex = 0;
            else
                currentIndex = (currentIndex + 1) % barModel.count;
            ensureVisible();
        }
    }
    Keys.onReturnPressed: executeCurrent()
    Keys.onEnterPressed: executeCurrent()

    function executeCurrent() {
        if (barModel.count === 0 || currentIndex === -1)
            return;

        let selectedBar = barModel.get(currentIndex).barName;
        if (barRoot.activeBar === selectedBar.toLowerCase())
            return;

        barRoot.activeBar = selectedBar.toLowerCase();
        let scriptPath = Quickshell.env("HOME") + "/.config/quickshell/scripts/bar.sh";
        Quickshell.execDetached(["bash", scriptPath, selectedBar]);
    }

    function ensureVisible() {
        let itemTop = currentIndex * 64;
        let itemBottom = itemTop + 52;

        if (itemTop < flickView.contentY) {
            flickView.contentY = itemTop;
        } else if (itemBottom > flickView.contentY + flickView.height) {
            flickView.contentY = itemBottom - flickView.height;
        }
    }

    ListModel {
        id: barModel
    }

    Process {
        id: getActiveProc
        command: ["bash", "-c", "cat ~/.cache/current_bar 2>/dev/null || echo 'tact'"]
        stdout: SplitParser {
            onRead: data => {
                let name = data.trim();
                if (name !== "") {
                    barRoot.activeBar = name.toLowerCase();
                }
            }
        }
    }

    Process {
        id: scanBarsProc
        command: ["bash", "-c", "ls -1 ~/.config/quickshell/switch/ 2>/dev/null"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                let name = data.trim();
                if (name !== "") {
                    barModel.append({
                        "barName": name
                    });
                }
            }
        }
    }

    Column {
        anchors.fill: parent
        spacing: 12

        // --- HEADER ---
        Item {
            width: parent.width
            height: 32

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: backArea.containsMouse ? Colors.bg2 : "transparent"
                    border.color: Colors.bg2
                    border.width: 2

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: ""
                        color: Colors.fg2
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 14
                    }
                    MouseArea {
                        id: backArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: barRoot.closeMenu()
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Bar Layouts"
                    color: Colors.fg0
                    font.pixelSize: 16
                    font.bold: true
                    font.family: "SF Pro Display"
                }
            }
        }

        // --- DYNAMIC LIST OF BARS ---
        Flickable {
            id: flickView
            width: parent.width
            height: parent.height - 44
            contentHeight: listCol.height
            clip: true

            Behavior on contentY {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutCubic
                }
            }

            Column {
                id: listCol
                width: parent.width
                spacing: 12

                Repeater {
                    model: barModel

                    Rectangle {
                        id: delegateRect
                        required property string barName
                        required property int index

                        width: parent.width
                        height: 52
                        radius: 16

                        property bool isActive: barRoot.activeBar === delegateRect.barName.toLowerCase()
                        property bool isFocused: barRoot.currentIndex === index

                        color: (mouseArea.containsMouse || isFocused) ? Colors.bg2 : Colors.bg1
                        border.color: isActive ? Colors.aqua : ((mouseArea.containsMouse || isFocused) ? Colors.bg3 : "transparent")
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

                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 16

                            Text {
                                text: "󰹯"
                                color: delegateRect.isActive ? Colors.aqua : Colors.fg2
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 18
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: delegateRect.barName
                                color: delegateRect.isActive ? Colors.aqua : Colors.fg0
                                font.family: "SF Pro Display"
                                font.pixelSize: 15
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        // Checkmark indicator
                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            text: "󰄬"
                            color: Colors.aqua
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 18
                            visible: delegateRect.isActive
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onEntered: barRoot.currentIndex = delegateRect.index

                            onClicked: {
                                if (delegateRect.isActive)
                                    return;

                                barRoot.activeBar = delegateRect.barName.toLowerCase();

                                let scriptPath = Quickshell.env("HOME") + "/.config/quickshell/scripts/bar.sh";
                                Quickshell.execDetached(["bash", scriptPath, delegateRect.barName]);
                            }
                        }
                    }
                }
            }
        }
    }
}
