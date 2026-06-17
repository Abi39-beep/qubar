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
    readonly property bool alwaysShowPill: true

    // --- Positioning ---
    readonly property int topMargin: 10

    // --- Morphing Animation Properties ---
    readonly property int animDuration: 380
    readonly property int animEasing: Easing.OutExpo

    // --- Equalizer Settings ---
    readonly property int eqBarCount: 4
    readonly property int eqBarWidth: 3
    readonly property int eqBarSpacing: 4
    readonly property int eqMaxHeight: 18
    readonly property int eqMinHeight: 3
    readonly property int eqAnimDuration: 180

    // --- Pop-up/Expanded State ---
    readonly property int expandedHeight: 59
    readonly property int expandedWidth: 480
    readonly property int dashboardSpacing: 24 // Adjust this number to control the gap!

    // --- System Pill Settings ---
    readonly property bool showWifi: true
    readonly property bool showBattery: true

    // Pill Container
    readonly property int sysPillHeight: 32
    readonly property int sysPillRadius: 16
    readonly property int sysPillPadding: 24   // Total horizontal padding added to the width
    readonly property int sysPillSpacing: 12   // The gap between the Wi-Fi icon and the Battery

    // Wi-Fi Icon
    readonly property int wifiIconWidth: 22
    readonly property int wifiIconHeight: 16
    readonly property real wifiLineWidth: 2.5

    // Battery Body
    readonly property int batteryWidth: 34
    readonly property int batteryHeight: 17
    readonly property int batteryRadius: 4
    readonly property int batteryBorderWidth: 2

    // Battery Inner Fill
    readonly property int batteryFillGap: 1    // The empty space between the border and the green fill
    readonly property int batteryFillRadius: 2

    // Battery Tip
    readonly property int batteryTipWidth: 2
    readonly property int batteryTipHeight: 6
    readonly property int batteryTipRadius: 1
    readonly property int batteryTipSpacing: 2 // The gap between the main body and the tip

    // Battery Typography & Alignment
    readonly property int fontSizeBattery: 10
    readonly property int batteryTextOffsetX: -1 // Visually centers the text away from the tip
    readonly property int batteryTextOffsetY: 1  // Pushes the text down to fix font baseline padding

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

    // --- App Launcher Settings ---
    readonly property string terminalEmulator: "kitty"
    readonly property int launcherMaxItems: 6
    readonly property int launcherWidth: 450
    readonly property int launcherRadius: 24

    // Search Bar
    readonly property int searchBarHeight: 44
    readonly property int searchBarRadius: 12
    readonly property int fontSizeSearchIcon: 20
    readonly property int fontSizeSearchInput: 15

    // App List Items
    readonly property int appItemHeight: 44
    readonly property int appItemRadius: 12
    readonly property int appIconSize: 28
    readonly property int fontSizeAppTitle: 15

    // --- OSD Settings ---
    readonly property int osdWidth: 260       // Increased to give the bar more room to stretch!
    readonly property int osdHeight: 50
    readonly property int osdRadius: 30

    // OSD Internal Spacing
    readonly property int osdMargin: 16       // Distance from the outer edge of the pill
    readonly property int osdSpacing: 10      // Distance between icon, bar, and text

    // OSD Typography
    readonly property int fontSizeOsdIcon: 22
    readonly property int fontSizeOsdText: 14

    // OSD Component Dimensions
    readonly property int osdIconWidth: 30
    readonly property int osdTextWidth: 40
    readonly property int osdBarHeight: 8

    // --- Notification Engine ---
    readonly property int notifWidth: 360
    readonly property int notifHeight: 70
    readonly property int notifRadius: 20
    readonly property int notifDefaultTimeout: 5000 // 5 seconds

    // Layout & Spacing
    readonly property int notifMargin: 16
    readonly property int notifSpacing: 12

    // Icon Settings
    readonly property int notifIconBoxSize: 38
    readonly property int notifIconBoxRadius: 10
    readonly property int notifIconFontSize: 20
    readonly property string notifDefaultIcon: "󰂚" // Fallback bell icon

    // Typography
    readonly property int fontSizeNotifTitle: 14
    readonly property int fontSizeNotifBody: 12

    // Timeout Progress Bar
    readonly property int notifBarHeight: 4
    readonly property int notifBarBottomMargin: 8

    // --- Control Center Settings ---
    readonly property int ccWidth: 400  // Increased width to fit the wide buttons
    readonly property int ccHeight: 340 // Adjusted height to fit the new layout perfectly
    readonly property int ccRadius: 24

    // Internal Spacing
    readonly property int ccPadding: 20
    readonly property int ccSpacing: 16

    // Toggle Buttons (Wide Pill Style)
    readonly property int ccToggleHeight: 60
    readonly property int ccToggleRadius: ccToggleHeight / 2 // This makes them perfect pills!
    readonly property int fontSizeCcToggleIcon: 20
    readonly property int fontSizeCcToggleTitle: 14
    readonly property int fontSizeCcToggleSub: 11

    // Sliders
    readonly property int ccSliderHeight: 40
    readonly property int ccSliderRadius: 24
    readonly property int fontSizeCcSliderIcon: 20
}
