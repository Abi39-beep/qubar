import QtQuick
import Quickshell
import Quickshell.Io
import QtQml.Models

Item {
    id: wallRoot
    signal backRequested

    property string activeWallpaper: ""

    // Regrab focus when opened
    onVisibleChanged: {
        if (visible) {
            grid.forceActiveFocus();
        }
    }

    ListModel {
        id: wallModel
    }

    // ==========================================
    // 1. FETCH ACTIVE THEME'S WALLPAPERS
    // ==========================================
    Process {
        id: fetchProc
        command: ["bash", "-c", "theme=$(cat ~/.cache/current_theme); find ~/.config/color-scheme/$theme -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) | sort"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                let path = data.trim();
                if (path !== "") {
                    wallModel.append({
                        filePath: path
                    });
                }
            }
        }
        onExited: {
            grid.forceActiveFocus();
            if (grid.currentIndex === -1)
                grid.currentIndex = 0;
            getActiveWall.running = true;
        }
    }

    // ==========================================
    // 2. DETECT CURRENTLY APPLIED WALLPAPER
    // ==========================================
    Process {
        id: getActiveWall
        command: ["bash", "-c", "readlink -f ~/.cache/current_wallpaper"]
        stdout: SplitParser {
            onRead: data => {
                let path = data.trim();
                wallRoot.activeWallpaper = path;

                // Smart Highlight: Automatically move the keyboard to the active wallpaper!
                for (let i = 0; i < wallModel.count; i++) {
                    if (wallModel.get(i).filePath === path) {
                        grid.currentIndex = i;
                        break;
                    }
                }
            }
        }
    }

    function applyWallpaper(path) {
        wallRoot.activeWallpaper = path;
        let scriptPath = Quickshell.env("HOME") + "/.config/quickshell/scripts/set_wallpaper.sh";
        Quickshell.execDetached(["bash", scriptPath, path]);
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

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

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
                        onClicked: wallRoot.backRequested()
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Wallpapers"
                    font.family: Config.fontName
                    font.pixelSize: 16
                    font.bold: true
                    color: Colors.fg0
                }
            }
        }

        // --- WALLPAPER KEYBOARD GRID ---
        // (Separator line was removed, so this flows right underneath the header)
        GridView {
            id: grid
            width: parent.width
            height: parent.height - 52 // Perfectly spans the remaining window space
            cellWidth: parent.width / 2
            cellHeight: 120
            model: wallModel
            clip: true

            focus: true
            keyNavigationEnabled: true
            keyNavigationWraps: true

            Keys.onReturnPressed: {
                if (currentIndex >= 0 && currentIndex < wallModel.count) {
                    applyWallpaper(wallModel.get(currentIndex).filePath);
                }
            }

            delegate: Item {
                width: grid.cellWidth
                height: grid.cellHeight

                // THE OUTER CONTAINER: Handles the Border perfectly
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 8
                    radius: 12
                    color: "transparent"

                    property bool isActive: wallRoot.activeWallpaper === filePath
                    property bool isFocused: grid.currentIndex === index

                    border.color: isActive ? Colors.aqua : (isFocused ? Colors.bg4 : "transparent")
                    border.width: isActive ? 3 : (isFocused ? 2 : 0)

                    Behavior on border.color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    // THE INNER CONTAINER: The actual image
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 4
                        radius: 8
                        clip: true
                        color: Colors.bg1

                        Image {
                            anchors.fill: parent
                            source: "file://" + filePath
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: true
                            sourceSize.width: 300
                            sourceSize.height: 200
                        }

                        // Subtle darken when hovered
                        Rectangle {
                            anchors.fill: parent
                            color: mouseArea.containsMouse ? Qt.rgba(0, 0, 0, 0.3) : "transparent"
                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                }
                            }
                        }
                    }

                    // (The Checkmark Badge was completely removed here)

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            grid.currentIndex = index;
                            grid.forceActiveFocus();
                            applyWallpaper(filePath);
                        }
                    }
                }
            }
        }
    }
}
