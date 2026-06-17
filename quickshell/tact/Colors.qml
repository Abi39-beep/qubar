pragma Singleton
import QtQuick

QtObject {
    // Background colors
    readonly property color bg0: "#040e0d"
    readonly property color bg1: "#0a1816"
    readonly property color bg2: "#0f211f"
    readonly property color bg3: "#152a26"
    readonly property color bg4: "#1d3631"

    // Foreground colors (fg1-fg3 derived from fg for compatibility with your setup)
    readonly property color fg: "#f5e2c5"
    readonly property color fg0: "#f5e2c5"
    readonly property color fg1: "#e1cdb0"
    readonly property color fg2: "#cdb99c"
    readonly property color fg3: "#baa68a"

    // Accent colors
    readonly property color red: "#ff6048"
    readonly property color orange: "#ffa478"
    readonly property color yellow: "#f5cd5b"
    readonly property color green: "#7ad9a8"
    readonly property color aqua: "#3dd1b0"
    readonly property color blue: "#5fc8d4"
    readonly property color purple: "#e89aa8"

    // Greyscale colors
    readonly property color grey0: "#3a1a35"
    readonly property color grey1: "#5a4d3e"
    readonly property color grey2: "#c4b09a"
}
