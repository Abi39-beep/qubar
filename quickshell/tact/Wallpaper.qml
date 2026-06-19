import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: wallpaperRoot
    color: Colors.bg0

    // Force it to the absolute background
    WlrLayershell.layer: WlrLayer.Background

    // THE FIX: Tell the wallpaper to ignore the space reserved by your top bar!
    // This forces it to cover 100% of the screen.
    exclusionMode: ExclusionMode.Ignore

    // Stretch to all 4 corners of the monitor
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    Image {
        anchors.fill: parent

        // Dynamic loading bypassing the cache
        source: "file://" + Quickshell.env("HOME") + "/.cache/current_wallpaper?" + new Date().getTime()

        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        smooth: true
        mipmap: true
    }
}
