import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: bgWindow
        required property var modelData
        screen: modelData

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        WlrLayershell.layer: WlrLayer.Background
        WlrLayershell.namespace: "desktop_wallpaper"
        exclusionMode: ExclusionMode.Ignore

        // Match the background color to the current theme so there is never a "black" screen during reload!
        color: Colors.bg0

        property string currentWall: ""

        Image {
            anchors.fill: parent
            source: bgWindow.currentWall
            fillMode: Image.PreserveAspectCrop
            cache: true
            sourceSize.width: bgWindow.width
            sourceSize.height: bgWindow.height
        }

        // Boot-loader: Read cache file instantly when Quickshell boots up
        Process {
            id: startupWall
            command: ["bash", "-c", "cat ~/.cache/current_wallpaper 2>/dev/null"]
            running: true
            stdout: SplitParser {
                onRead: data => {
                    let path = data.trim();
                    if (path !== "")
                        bgWindow.currentWall = encodeURI("file://" + path);
                }
            }
        }

        // Live updater: Refreshes natively when you click a Wallpaper in your menu
        Timer {
            interval: 500
            running: true
            repeat: true
            onTriggered: checkWallProc.running = true
        }

        Process {
            id: checkWallProc
            command: ["bash", "-c", "cat ~/.cache/current_wallpaper 2>/dev/null"]
            stdout: SplitParser {
                onRead: data => {
                    let path = data.trim();
                    if (path !== "") {
                        let formatted = encodeURI("file://" + path);
                        if (bgWindow.currentWall !== formatted) {
                            bgWindow.currentWall = formatted;
                        }
                    }
                }
            }
        }
    }
}
