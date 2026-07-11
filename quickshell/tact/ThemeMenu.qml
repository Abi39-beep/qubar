pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io

Item {
    id: themeRoot
    signal backRequested

    property string activeTheme: ""
    property var themeData: []
    property string pendingTheme: ""

    // ==========================================
    // 1. IMPORT THE PERFECTED THEME ENGINE
    // ==========================================
    ThemeEngine {
        id: themeEngine
    }

    // ==========================================
    // 2. THEME DATA ENGINE (One-Time Startup Fetch)
    // ==========================================
    Process {
        id: getActiveProc
        command: ["bash", "-c", "cat ~/.cache/current_theme || echo 'Unknown'"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                themeRoot.activeTheme = data.trim();
            }
        }
    }

    Process {
        id: scanThemesProc
        // THE FIX: Pointed to quickshell/themes instead of color-scheme!
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
                if (!line) continue;

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
            scanThemesProc.themeBuffer = ""; // Clear memory
        }
    }

    // ==========================================
    // 3. UI LAYOUT
    // ==========================================
    Column {
        anchors.fill: parent
        spacing: 16

        // --- HEADER ---
        Item {
            width: parent.width
            height: 36

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                Rectangle {
                    width: 36
                    height: 36
                    radius: 18
                    color: backArea.containsMouse ? Colors.bg2 : Colors.bg1
                    border.color: Colors.bg3
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        anchors.centerIn: parent
                        text: "󰁍"
                        font.family: Config.fontName
                        font.pixelSize: 18
                        color: Colors.fg0
                    }
                    MouseArea {
                        id: backArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: themeRoot.backRequested()
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Themes"
                    font.family: Config.fontName
                    font.pixelSize: 16
                    font.bold: true
                    color: Colors.fg0
                }
            }
        }

        // --- DYNAMIC THEME GRID ---
        Flickable {
            width: parent.width
            height: parent.height - 53
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

                        Behavior on border.color { ColorAnimation { duration: 150 } }

                        Rectangle {
                            anchors.fill: parent
                            radius: 12
                            color: mouseArea.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent"
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }

                        Column {
                            anchors.centerIn: parent
                            spacing: 12

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "󰑐"
                                font.family: Config.fontName
                                font.pixelSize: 18
                                color: delegateRect.modelData.accHex
                                visible: delegateRect.isApplying

                                RotationAnimation on rotation {
                                    loops: Animation.Infinite
                                    from: 0; to: 360
                                    duration: 1000
                                    running: delegateRect.isApplying
                                }
                            }

                            Rectangle {
                                width: 28; height: 6; radius: 3
                                color: delegateRect.modelData.accHex
                                anchors.horizontalCenter: parent.horizontalCenter
                                visible: !delegateRect.isApplying
                            }

                            Text {
                                text: delegateRect.modelData.name
                                color: delegateRect.isSelected ? delegateRect.modelData.accHex : Colors.fg1
                                font.family: Config.fontName
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
                                if (themeRoot.activeTheme === delegateRect.modelData.name || themeRoot.pendingTheme !== "") return;

                                themeRoot.pendingTheme = delegateRect.modelData.name;
                                // THE FIX: Use the native engine instead of the bash script!
                                themeEngine.applyTheme(delegateRect.modelData.name);
                            }
                        }
                    }
                }
            }
        }
    }
}
