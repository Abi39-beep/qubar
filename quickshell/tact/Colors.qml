pragma Singleton
import QtQuick

QtObject {
    // Horizon Background colors (Warm, deep purplish-greys)
    readonly property color bg0: "#1C1E26" // Main background
    readonly property color bg1: "#232530" // Lighter background (panels/sidebars)
    readonly property color bg2: "#2E303E" // Cursorline / Hover state
    readonly property color bg3: "#44465B" // Selection background
    readonly property color bg4: "#1A1C23" // Darker terminal/shadow background

    // Foreground colors (Soft whites and creams)
    readonly property color fg: "#D5D8DA"  // Main text
    readonly property color fg0: "#D5D8DA"
    readonly property color fg1: "#FDF0ED" // Bright white/cream text
    readonly property color fg2: "#CBCED0" // Muted text
    readonly property color fg3: "#A5A6A9" // Deeper muted text

    // Accent colors (Vibrant neon pastels)
    readonly property color red: "#E95678"    // Coral Red
    readonly property color orange: "#F09383" // Peach Orange
    readonly property color yellow: "#FAC29A" // Soft Gold/Yellow
    readonly property color green: "#29D398"  // Neon Mint Green
    readonly property color aqua: "#59E1E3"   // Glowing Cyan
    readonly property color blue: "#26BBD9"   // Bright Azure Blue
    readonly property color purple: "#EE64AC" // Magenta/Pink

    // Greyscale / Muted colors
    readonly property color grey0: "#6C6F93"  // Muted comments/invisible text
    readonly property color grey1: "#44465B"  // Lighter grey borders
    readonly property color grey2: "#2E303E"  // Darker UI element borders
}
