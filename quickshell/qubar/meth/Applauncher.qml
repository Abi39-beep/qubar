import QtQuick
import QtQuick.Controls.Basic
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Wayland
import ".."

PanelWindow {
    id: launcherRoot

    // --- WAYLAND SETUP ---
    WlrLayershell.namespace: "app_launcher"
    screen: Quickshell.primaryScreen
    focusable: true

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: false

    // --- CONFIGURATION PROPERTIES ---
    property int searchBarHeight: 40
    property int searchBarRadius: 12
    property int appItemHeight: 40
    property int appItemRadius: 12
    property int appIconSize: 28
    property int launcherMaxItems: 6
    property int fontSizeSearchIcon: 16
    property int fontSizeSearchInput: 14
    property int fontSizeAppTitle: 14
    property string fontName: "SF Mono Propo"
    property string terminalEmulator: "kitty"

    // --- STATE DATA ---
    property bool isClipboardMode: false
    property var allClips: []
    property string clipBuffer: ""
    property var pendingApp: null
    property string pendingCommand: ""

    // ==========================================
    // 1. GLOBAL ACTION FUNCTIONS
    // ==========================================
    function launchApp(appModel) {
        let needsTerm = appModel.terminal || appModel.runInTerminal || false;

        if (needsTerm) {
            let baseCmd = "";
            if (appModel.command && appModel.command.length > 0) {
                baseCmd = appModel.command[0];
            } else if (appModel.executable) {
                baseCmd = String(appModel.executable).split(" ")[0];
            } else {
                baseCmd = String(appModel.name).toLowerCase().replace(/ /g, "");
            }
            launcherRoot.pendingCommand = launcherRoot.terminalEmulator + " -e " + baseCmd;
            launcherRoot.pendingApp = null;
        } else {
            launcherRoot.pendingApp = appModel;
            launcherRoot.pendingCommand = "";
        }
        launcherRoot.visible = false;
        execTimer.restart();
    }

    function copyClip(clipModel) {
        let safeLine = clipModel.rawLine.replace(/'/g, "'\\''");
        Quickshell.execDetached(["bash", "-c", "echo -E '" + safeLine + "' | cliphist decode | wl-copy"]);
        launcherRoot.visible = false;
    }

    function clearClipboard() {
        Quickshell.execDetached(["cliphist", "wipe"]);
        launcherRoot.allClips = [];
        searchInput.forceActiveFocus();
    }

    // ==========================================
    // 2. BACKGROUND PROCESSES & TIMERS
    // ==========================================
    Timer {
        id: execTimer
        interval: 350
        onTriggered: {
            if (launcherRoot.pendingApp) {
                launcherRoot.pendingApp.execute();
                launcherRoot.pendingApp = null;
            } else if (launcherRoot.pendingCommand !== "") {
                Quickshell.execDetached(["bash", "-lc", launcherRoot.pendingCommand]);
                launcherRoot.pendingCommand = "";
            }
        }
    }

    Timer {
        id: focusStealTimer
        interval: 150
        onTriggered: searchInput.forceActiveFocus()
    }

    // qmllint disable signal-handler-parameters
    Process {
        id: clipProc
        command: ["bash", "-c", "cliphist list | head -n 50"]
        running: false

        stdout: SplitParser {
            onRead: data => {
                launcherRoot.clipBuffer += data + "\n";
            }
        }

        onExited: {
            let lines = launcherRoot.clipBuffer.split("\n");
            let tempArr = [];
            for (let i = 0; i < lines.length; i++) {
                let line = lines[i].trim();
                if (!line)
                    continue;
                let sep = line.indexOf("\t");
                if (sep > -1) {
                    tempArr.push({
                        clipId: line.substring(0, sep),
                        content: line.substring(sep + 1).trim(),
                        rawLine: line
                    });
                }
            }
            launcherRoot.allClips = tempArr;
            launcherRoot.clipBuffer = "";
        }
    }

    onVisibleChanged: {
        if (visible) {
            launcherRoot.isClipboardMode = false;
            searchInput.text = "";
            appList.contentY = 0;
            appList.currentIndex = 0;
            clipList.contentY = 0;
            clipList.currentIndex = 0;

            launcherRoot.clipBuffer = "";
            clipProc.running = false;
            clipProc.running = true;
            focusStealTimer.restart();
        } else {
            focusStealTimer.stop();
        }
    }

    // --- SMART HEIGHT MATH ---
    property int dynamicHeight: {
        if (!clipList || !appList)
            return 300;
        let activeList = launcherRoot.isClipboardMode ? clipList : appList;
        let count = activeList ? activeList.count : 0;
        let visibleItems = Math.min(count, launcherMaxItems);
        let listHeight = visibleItems > 0 ? (visibleItems * (appItemHeight + 6)) - 6 : 0;
        let baseHeight = searchBarHeight + 56;
        return listHeight > 0 ? (baseHeight + listHeight) : baseHeight;
    }

    // ==========================================
    // 3. UI & LAYOUT
    // ==========================================
    Item {
        anchors.fill: parent

        MouseArea {
            anchors.fill: parent
            onClicked: launcherRoot.visible = false
        }

        Rectangle {
            anchors.centerIn: parent
            width: 450
            height: launcherRoot.dynamicHeight
            color: Colors.bg0
            radius: 24
            border.color: Colors.bg2
            border.width: 2
            clip: true

            transformOrigin: Item.Center
            scale: launcherRoot.visible ? 1.0 : 0.75
            opacity: launcherRoot.visible ? 1.0 : 0.0

            Behavior on scale {
                NumberAnimation {
                    duration: 350
                    easing.type: Easing.OutBack
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }
            }

            Behavior on height {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutQuart
                }
            }

            MouseArea {
                anchors.fill: parent
            }

            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16

                // --- THE SEARCH BAR ---
                Rectangle {
                    id: searchBar
                    width: parent.width
                    height: launcherRoot.searchBarHeight
                    radius: launcherRoot.searchBarRadius
                    color: Colors.bg2
                    border.color: searchInput.activeFocus ? (launcherRoot.isClipboardMode ? Colors.aqua : Colors.green) : Colors.bg3
                    border.width: 2

                    property bool showClear: launcherRoot.isClipboardMode && launcherRoot.allClips.length > 0

                    Behavior on border.color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    Row {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: launcherRoot.isClipboardMode ? "󰅍" : ""
                            font.family: launcherRoot.fontName
                            font.pixelSize: launcherRoot.fontSizeSearchIcon
                            color: searchInput.activeFocus ? (launcherRoot.isClipboardMode ? Colors.aqua : Colors.green) : Colors.fg2
                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                }
                            }
                        }

                        TextField {
                            id: searchInput
                            focus: true
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - (launcherRoot.fontSizeSearchIcon + 24) - (searchBar.showClear ? 40 : 0)
                            color: Colors.fg0
                            font.family: launcherRoot.fontName
                            font.pixelSize: launcherRoot.fontSizeSearchInput
                            background: null
                            placeholderText: launcherRoot.isClipboardMode ? "Search clipboard... (Tab to switch)" : "Search apps... (Tab to switch)"
                            placeholderTextColor: Colors.bg4

                            onTextChanged: {
                                appList.currentIndex = 0;
                                clipList.currentIndex = 0;
                            }

                            Keys.onPressed: event => {
                                let activeList = launcherRoot.isClipboardMode ? clipList : appList;

                                if (event.key === Qt.Key_Down) {
                                    if (activeList.currentIndex < activeList.count - 1)
                                        activeList.currentIndex++;
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Up) {
                                    if (activeList.currentIndex > 0)
                                        activeList.currentIndex--;
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Escape) {
                                    launcherRoot.visible = false;
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Tab) {
                                    launcherRoot.isClipboardMode = !launcherRoot.isClipboardMode;
                                    event.accepted = true;
                                }
                            }

                            onAccepted: {
                                if (launcherRoot.isClipboardMode) {
                                    if (clipList.count > 0 && clipList.currentIndex >= 0) {
                                        launcherRoot.copyClip(clipList.model.values[clipList.currentIndex]);
                                    }
                                } else {
                                    if (appList.count > 0 && appList.currentIndex >= 0) {
                                        launcherRoot.launchApp(appList.model.values[appList.currentIndex]);
                                    } else if (text.trim() !== "") {
                                        launcherRoot.pendingCommand = text.trim();
                                        launcherRoot.pendingApp = null;
                                        launcherRoot.visible = false;
                                        execTimer.restart();
                                    }
                                }
                            }
                        }
                    }

                    // Integrated Clear All Icon
                    Rectangle {
                        anchors.right: parent.right
                        anchors.rightMargin: 6
                        anchors.verticalCenter: parent.verticalCenter
                        width: 32
                        height: 32
                        radius: 6
                        visible: searchBar.showClear
                        color: clearArea.containsMouse ? Qt.rgba(Colors.red.r, Colors.red.g, Colors.red.b, 0.15) : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "󰃢"
                            color: clearArea.containsMouse ? Colors.red : Colors.fg2
                            font.family: launcherRoot.fontName
                            font.pixelSize: 16
                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                }
                            }
                        }

                        MouseArea {
                            id: clearArea
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: launcherRoot.clearClipboard()
                        }
                    }
                }

                // --- LIST 1: APP LAUNCHER ---
                ListView {
                    id: appList
                    width: parent.width
                    height: parent.height - searchBar.height - 16
                    clip: true
                    spacing: 6
                    visible: !launcherRoot.isClipboardMode
                    highlightFollowsCurrentItem: true
                    currentIndex: 0

                    model: ScriptModel {
                        objectProp: "id"
                        values: {
                            let search = String(searchInput.text).toLowerCase().trim();
                            let allApps = [...DesktopEntries.applications.values];

                            if (search === "")
                                return allApps;

                            return allApps.filter(app => {
                                let appName = String(app.name || "").toLowerCase();
                                let execName = String(app.executable || "").toLowerCase();
                                let genName = String(app.genericName || "").toLowerCase();

                                if (appName.includes(search) || execName.includes(search) || genName.includes(search))
                                    return true;

                                if (app.keywords) {
                                    for (let i = 0; i < app.keywords.length; i++) {
                                        if (String(app.keywords[i]).toLowerCase().includes(search))
                                            return true;
                                    }
                                }
                                return false;
                            });
                        }
                    }

                    delegate: Rectangle {
                        id: delegateRect
                        required property var modelData
                        required property int index

                        width: ListView.view.width
                        height: launcherRoot.appItemHeight
                        radius: launcherRoot.appItemRadius

                        property bool isSelected: ListView.isCurrentItem || appArea.containsMouse
                        color: isSelected ? Colors.bg2 : "transparent"
                        border.color: isSelected ? Colors.bg3 : "transparent"
                        border.width: 2

                        MouseArea {
                            id: appArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                appList.currentIndex = delegateRect.index;
                                launcherRoot.launchApp(delegateRect.modelData);
                            }
                        }

                        Row {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 16

                            IconImage {
                                anchors.verticalCenter: parent.verticalCenter
                                width: launcherRoot.appIconSize
                                height: launcherRoot.appIconSize
                                source: delegateRect.modelData.icon ? Quickshell.iconPath(delegateRect.modelData.icon) : ""
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: delegateRect.modelData.name || ""
                                color: delegateRect.isSelected ? Colors.green : Colors.fg0
                                font.family: launcherRoot.fontName
                                font.pixelSize: launcherRoot.fontSizeAppTitle
                                font.bold: true
                            }
                        }
                    }
                }

                // --- LIST 2: CLIPBOARD HISTORY ---
                ListView {
                    id: clipList
                    width: parent.width
                    height: parent.height - searchBar.height - 16
                    clip: true
                    spacing: 6
                    visible: launcherRoot.isClipboardMode
                    highlightFollowsCurrentItem: true
                    currentIndex: 0

                    model: ScriptModel {
                        objectProp: "clipId"
                        values: {
                            let triggerUpdate = launcherRoot.allClips;
                            let search = String(searchInput.text).toLowerCase().trim();
                            if (search === "")
                                return triggerUpdate;

                            return triggerUpdate.filter(clip => {
                                let clipText = String(clip.content || "").toLowerCase();
                                return clipText.includes(search);
                            });
                        }
                    }

                    delegate: Rectangle {
                        id: clipDelegateRect
                        required property var modelData
                        required property int index

                        width: ListView.view.width
                        height: launcherRoot.appItemHeight
                        radius: launcherRoot.appItemRadius

                        property bool isRowHovered: clipArea.containsMouse || copyHoverArea.containsMouse || delHoverArea.containsMouse
                        property bool isSelected: ListView.isCurrentItem || isRowHovered

                        color: isSelected ? Colors.bg2 : "transparent"
                        border.color: isSelected ? Colors.bg3 : "transparent"
                        border.width: 2

                        MouseArea {
                            id: clipArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                clipList.currentIndex = clipDelegateRect.index;
                                launcherRoot.copyClip(clipDelegateRect.modelData);
                            }
                        }

                        Row {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 16

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: "󰅍"
                                color: clipDelegateRect.isSelected ? Colors.aqua : Colors.fg2
                                font.family: launcherRoot.fontName
                                font.pixelSize: 18
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - 110
                                text: clipDelegateRect.modelData.content
                                color: clipDelegateRect.isSelected ? Colors.aqua : Colors.fg0
                                font.family: launcherRoot.fontName
                                font.pixelSize: launcherRoot.fontSizeAppTitle
                                elide: Text.ElideRight
                            }
                        }

                        Row {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: 12
                            spacing: 8
                            visible: clipDelegateRect.isRowHovered

                            Rectangle {
                                id: copyIconRect
                                width: 32
                                height: 32
                                radius: 6
                                color: copyHoverArea.containsMouse ? Colors.bg3 : "transparent"
                                property bool isCopied: false

                                Text {
                                    anchors.centerIn: parent
                                    text: copyIconRect.isCopied ? "󰄬" : "󰆏"
                                    color: copyIconRect.isCopied ? Colors.green : Colors.fg2
                                    font.family: launcherRoot.fontName
                                    font.pixelSize: 16
                                }

                                Timer {
                                    id: tickTimer
                                    interval: 1500
                                    onTriggered: copyIconRect.isCopied = false
                                }

                                MouseArea {
                                    id: copyHoverArea
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    onClicked: {
                                        let safeLine = clipDelegateRect.modelData.rawLine.replace(/'/g, "'\\''");
                                        Quickshell.execDetached(["bash", "-c", "echo -E '" + safeLine + "' | cliphist decode | wl-copy"]);
                                        copyIconRect.isCopied = true;
                                        tickTimer.restart();
                                        searchInput.forceActiveFocus();
                                    }
                                }
                            }

                            Rectangle {
                                width: 32
                                height: 32
                                radius: 6
                                color: delHoverArea.containsMouse ? Qt.rgba(Colors.red.r, Colors.red.g, Colors.red.b, 0.15) : "transparent"

                                Text {
                                    anchors.centerIn: parent
                                    text: "󰆴"
                                    color: delHoverArea.containsMouse ? Colors.red : Colors.fg2
                                    font.family: launcherRoot.fontName
                                    font.pixelSize: 16
                                }

                                MouseArea {
                                    id: delHoverArea
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    onClicked: {
                                        let safeLine = clipDelegateRect.modelData.rawLine.replace(/'/g, "'\\''");
                                        Quickshell.execDetached(["bash", "-c", "echo -E '" + safeLine + "' | cliphist delete"]);
                                        launcherRoot.allClips = launcherRoot.allClips.filter(c => c.clipId !== clipDelegateRect.modelData.clipId);
                                        searchInput.forceActiveFocus();
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
