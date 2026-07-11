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

        color: Colors.bg0

        property url currentWall: ""
        property string cachePath: Quickshell.env("HOME") + "/.cache/current_wallpaper"

        Image {
            anchors.fill: parent
            source: bgWindow.currentWall
            fillMode: Image.PreserveAspectCrop
            cache: true
        }

        // Slower polling interval to avoid hammering the system
        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: {
                if (!checkWallProc.running) {
                    checkWallProc.running = true;
                }
            }
        }

        // Process to read the cached wallpaper path (runs instantly on boot, then via Timer)
        Process {
            id: checkWallProc
            command: ["sh", "-c", "cat \"$1\" 2>/dev/null", "--", bgWindow.cachePath]
            running: true
            stdout: SplitParser {
                onRead: data => {
                    const path = data.trim();
                    if (path !== "") {
                        const formattedUrl = path.startsWith("file:") ? path : "file:///" + path.replace(/^\/+/, "");

                        if (bgWindow.currentWall.toString() !== formattedUrl) {
                            bgWindow.currentWall = formattedUrl;
                        }
                    }
                }
            }
        }
    }
}
