pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io
import ".."

Item {
    id: themeRoot
    height: 288

    signal closeMenu

    property string activeTheme: ""
    property var themeData: []
    property string pendingTheme: ""

    Themeengine {
        id: themeEngine
    }

    onVisibleChanged: {
        if (visible) {
            forceActiveFocus();
        }
    }

    Keys.onEscapePressed: themeRoot.closeMenu()

    // ==========================================
    // 1. THEME DATA ENGINE
    // ==========================================
    Process {
        id: getActiveProc
        command: ["bash", "-c", "cat ~/.cache/current_theme 2>/dev/null || echo 'Unknown'"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                themeRoot.activeTheme = data.trim();
            }
        }
    }

    Process {
        id: scanThemesProc
        command: ["bash", "-c", "for d in ~/.config/quickshell/themes/*/; do name=$(basename \"$d\"); bg=$(grep 'readonly property color bg2' \"$d/quickshell/Colors.qml\" 2>/dev/null | cut -d'\"' -f2); acc=$(grep 'readonly property color aqua' \"$d/quickshell/Colors.qml\" 2>/dev/null | cut -d'\"' -f2); echo \"$name|${bg:-#152a26}|${acc:-#3dd1b0}\"; done"]
        running: true

        property string themeBuffer: ""

        stdout: SplitParser {
            onRead: data => {
                scanThemesProc.themeBuffer += data + "\n";
            }
        }

        // qmllint disable signal-handler-parameters
        onExited: {
            let lines = scanThemesProc.themeBuffer.split("\n");
            let tempArr = [];
            for (let i = 0; i < lines.length; i++) {
                let line = lines[i].trim();
                if (!line)
                    continue;

                let parts = line.split("|");
                if (parts.length === 3) {
                    tempArr.push({
                        name: parts[0],
                        bgHex: parts[1],
                        accHex: parts[2]
                    });
                }
            }
            themeRoot.themeData = tempArr;
            scanThemesProc.themeBuffer = "";
        }
    }

    // ==========================================
    // 2. UI LAYOUT
    // ==========================================
    Column {
        anchors.fill: parent
        spacing: 16

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
                        onClicked: themeRoot.closeMenu()
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Themes"
                    color: Colors.fg0
                    font.pixelSize: 16
                    font.bold: true
                    font.family: "SF Pro Display"
                }
            }
        }

        // --- DYNAMIC THEME GRID ---
        Flickable {
            width: parent.width
            height: parent.height - 48
            contentHeight: grid.height
            clip: true

            Grid {
                id: grid
                width: parent.width
                columns: 3
                spacing: 12

                Repeater {
                    model: themeRoot.themeData

                    Rectangle {
                        id: delegateRect
                        required property int index
                        required property var modelData

                        width: (parent.width - 24) / 3
                        height: 72
                        radius: 12
                        clip: true

                        property bool isSelected: themeRoot.activeTheme === modelData.name
                        property bool isApplying: themeRoot.pendingTheme === modelData.name

                        color: modelData.bgHex
                        border.color: isSelected ? modelData.accHex : "transparent"
                        border.width: 2

                        Behavior on border.color {
                            ColorAnimation {
                                duration: 150
                            }
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: 12
                            color: mouseArea.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent"
                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                }
                            }
                        }

                        Column {
                            anchors.centerIn: parent
                            spacing: 12

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "󰑐"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 18
                                color: delegateRect.modelData.accHex
                                visible: delegateRect.isApplying

                                RotationAnimation on rotation {
                                    loops: Animation.Infinite
                                    from: 0
                                    to: 360
                                    duration: 1000
                                    running: delegateRect.isApplying
                                }
                            }

                            Rectangle {
                                width: 28
                                height: 6
                                radius: 3
                                color: delegateRect.modelData.accHex
                                anchors.horizontalCenter: parent.horizontalCenter
                                visible: !delegateRect.isApplying
                            }

                            Text {
                                text: delegateRect.modelData.name
                                color: delegateRect.isSelected ? delegateRect.modelData.accHex : Colors.fg1
                                font.family: "SF Pro Display"
                                font.pixelSize: 13
                                font.bold: delegateRect.isSelected
                                anchors.horizontalCenter: parent.horizontalCenter
                                visible: !delegateRect.isApplying
                            }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (themeRoot.activeTheme === delegateRect.modelData.name || themeRoot.pendingTheme !== "")
                                    return;

                                themeRoot.pendingTheme = delegateRect.modelData.name;
                                themeEngine.applyTheme(delegateRect.modelData.name);
                            }
                        }
                    }
                }
            }
        }
    }
}
