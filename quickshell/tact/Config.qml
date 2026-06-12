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

    // --- System Pill ---
    readonly property bool showWifi: true
    readonly property bool showBattery: true
    readonly property int batteryWidth: 30 // Adjust this to make the battery longer or shorter!

    // --- Media Controller Settings ---
    readonly property int mediaCtrlWidth: 400
    readonly property int mediaCtrlHeight: 120
    readonly property int mediaCtrlRadius: 24
    readonly property real mediaCtrlArtOpacity: 0.85
    readonly property real mediaCtrlTintOpacity: 0.70

    // --- Power Menu Settings ---
    readonly property int powerMenuWidth: 350
    readonly property int powerMenuHeight: 70
    readonly property int powerMenuBoxSize: 50
    readonly property int powerMenuBoxRadius: 12
    readonly property int powerMenuSpacing: 12
    readonly property int powerMenuIconSize: 20
    readonly property int powerMenuCountdownSize: 20
    readonly property int powerMenuBorderWidth: 2
}
