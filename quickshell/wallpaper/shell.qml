import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

ShellRoot {
    PanelWindow {
        id: bgWindow

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        WlrLayershell.layer: WlrLayer.Background
        WlrLayershell.namespace: "desktop_wallpaper"
        exclusionMode: ExclusionMode.Ignore
        color: "black"

        property string activeLayer: "img1"

        IpcHandler {
            target: "wallpaper"
            function update(newPath: string): void {
                let fullPath = "file://" + newPath;

                if (bgWindow.activeLayer === "img1") {
                    if (img2.source == fullPath)
                        return;
                    img2.source = fullPath;
                } else {
                    if (img1.source == fullPath)
                        return;
                    img1.source = fullPath;
                }
            }
        }

        // --- BACKGROUND LAYER 1 ---
        Image {
            id: img1
            source: "file://" + Quickshell.env("HOME") + "/.cache/current_wallpaper"
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true

            // THE ULTIMATE OPTIMIZATION:
            // Forces the CPU to decode the image exactly to your screen resolution, saving massive RAM/CPU.
            sourceSize.width: bgWindow.width
            sourceSize.height: bgWindow.height

            opacity: bgWindow.activeLayer === "img1" ? 1 : 0
            // Sped up the animation slightly to feel more responsive (800ms)
            Behavior on opacity {
                NumberAnimation {
                    duration: 800
                    easing.type: Easing.OutCubic
                }
            }

            onStatusChanged: {
                if (status === Image.Ready && bgWindow.activeLayer !== "img1") {
                    bgWindow.activeLayer = "img1";
                }
            }
        }

        // --- BACKGROUND LAYER 2 ---
        Image {
            id: img2
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true

            sourceSize.width: bgWindow.width
            sourceSize.height: bgWindow.height

            opacity: bgWindow.activeLayer === "img2" ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 800
                    easing.type: Easing.OutCubic
                }
            }

            onStatusChanged: {
                if (status === Image.Ready && bgWindow.activeLayer !== "img2") {
                    bgWindow.activeLayer = "img2";
                }
            }
        }
    }
}
