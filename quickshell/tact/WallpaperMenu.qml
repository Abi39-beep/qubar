pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import QtQml.Models
import Qt5Compat.GraphicalEffects

Item {
    id: wallRoot
    signal backRequested

    property string activeWallpaper: ""

    Timer {
        id: grabFocusTimer
        interval: 100
        running: false
        onTriggered: {
            grid.forceActiveFocus();
        }
    }

    function resetSelection() {
        if (wallRoot.activeWallpaper === "")
            return;

        for (let i = 0; i < wallModel.count; i++) {
            if (wallModel.get(i).filePath === wallRoot.activeWallpaper) {
                grid.currentIndex = i;
                grid.positionViewAtIndex(i, GridView.Contain);
                break;
            }
        }
    }

    onVisibleChanged: {
        if (visible) {
            grabFocusTimer.restart();
            wallRoot.resetSelection();
        }
    }

    ListModel {
        id: wallModel
    }

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

        // qmllint disable signal-handler-parameters
        onExited: {
            if (grid.currentIndex === -1)
                grid.currentIndex = 0;
            getActiveWall.running = true;
            grabFocusTimer.restart();
        }
    }

    Process {
        id: getActiveWall
        command: ["bash", "-c", "readlink -f ~/.cache/current_wallpaper"]
        stdout: SplitParser {
            onRead: data => {
                let path = data.trim();
                wallRoot.activeWallpaper = path;
                wallRoot.resetSelection();
            }
        }
    }

    function applyWallpaper(path) {
        wallRoot.activeWallpaper = path;
        wallRoot.resetSelection();
        let scriptPath = Quickshell.env("HOME") + "/.config/quickshell/scripts/set_wallpaper.sh";
        Quickshell.execDetached(["bash", scriptPath, path]);
    }

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
        GridView {
            id: grid
            width: parent.width
            height: parent.height - 52
            cellWidth: parent.width / 2
            cellHeight: 120
            model: wallModel
            clip: true

            focus: true

            Keys.onLeftPressed: event => {
                if (currentIndex > 0)
                    currentIndex--;
                event.accepted = true;
            }

            Keys.onRightPressed: event => {
                if (currentIndex < wallModel.count - 1)
                    currentIndex++;
                event.accepted = true;
            }

            Keys.onUpPressed: event => {
                if (currentIndex >= 2)
                    currentIndex -= 2;
                event.accepted = true;
            }

            Keys.onDownPressed: event => {
                if (currentIndex + 2 < wallModel.count)
                    currentIndex += 2;
                else if (currentIndex + 1 < wallModel.count)
                    currentIndex++;
                event.accepted = true;
            }

            Keys.onReturnPressed: event => {
                if (currentIndex >= 0 && currentIndex < wallModel.count)
                    wallRoot.applyWallpaper(wallModel.get(currentIndex).filePath);
                event.accepted = true;
            }

            Keys.onEnterPressed: event => {
                if (currentIndex >= 0 && currentIndex < wallModel.count)
                    wallRoot.applyWallpaper(wallModel.get(currentIndex).filePath);
                event.accepted = true;
            }

            Keys.onEscapePressed: event => {
                wallRoot.backRequested();
                event.accepted = true;
            }

            delegate: Item {
                id: delegateRoot
                required property int index
                required property string filePath

                width: grid.cellWidth
                height: grid.cellHeight

                z: grid.currentIndex === index ? 10 : 1

                Item {
                    id: innerContainer
                    anchors.fill: parent
                    anchors.margins: 12

                    property bool isActive: wallRoot.activeWallpaper === delegateRoot.filePath
                    property bool isFocused: grid.currentIndex === delegateRoot.index

                    // The Pop Animation
                    scale: isFocused ? 1.08 : 1.0
                    Behavior on scale {
                        NumberAnimation {
                            duration: 250
                            easing.type: Easing.OutBack
                        }
                    }

                    // LAYER 1: RAW IMAGE
                    Image {
                        id: rawImg
                        anchors.fill: parent
                        source: "file://" + delegateRoot.filePath
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: true
                        sourceSize.width: 300
                        visible: false
                    }

                    // LAYER 2: ROUNDED STENCIL
                    Rectangle {
                        id: maskRect
                        anchors.fill: parent
                        radius: 12
                        visible: false
                    }

                    // LAYER 3: PERFECTLY CUT IMAGE
                    OpacityMask {
                        anchors.fill: parent
                        source: rawImg
                        maskSource: maskRect
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 12
                        color: mouseArea.containsMouse ? Qt.rgba(0, 0, 0, 0.3) : "transparent"
                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }
                    }

                    // LAYER 4: BORDER
                    Rectangle {
                        anchors.fill: parent
                        radius: 12
                        color: "transparent"
                        border.color: parent.isActive ? Colors.aqua : (parent.isFocused ? Colors.fg0 : "transparent")
                        border.width: parent.isActive ? 2 : (parent.isFocused ? 1 : 0)

                        Behavior on border.color {
                            ColorAnimation {
                                duration: 150
                            }
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            grid.currentIndex = delegateRoot.index;
                            grabFocusTimer.restart();
                            wallRoot.applyWallpaper(delegateRoot.filePath);
                        }
                    }
                }
            }
        }
    }
}
