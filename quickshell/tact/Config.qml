pragma Singleton
import QtQuick

QtObject {
    // --- Typography ---
    readonly property string fontName: "JetBrainsMono Nerd Font"
    readonly property int fontSizeTime: 16
    readonly property int fontSizeDate: 14
    readonly property int fontSizeWorkspace: 12
    readonly property int fontSizeMediaTitle: 13

    // --- Pill Dimensions ---
    readonly property int pillHeight: 40
    readonly property int timeWidth: 100
    readonly property int timeWithEqWidth: 140
    readonly property int expandedTimeWidth: 200

    // --- Positioning ---
    readonly property int topMargin: 12

    // --- Morphing Animation Properties ---
    readonly property int animDuration: 350
    readonly property int animEasing: Easing.OutExpo

    // --- Equalizer Settings ---
    readonly property int eqBarCount: 4
    readonly property int eqBarWidth: 3
    readonly property int eqBarSpacing: 4
    readonly property int eqMaxHeight: 18
    readonly property int eqMinHeight: 3
    readonly property int eqAnimDuration: 200

    // --- Pop-up/Expanded State ---
    readonly property int expandedHeight: 59
    readonly property int expandedWidth: 480
    readonly property int dashboardSpacing: 24 // Adjust this number to control the gap!
}
