import QtQuick
import QtQuick.Controls.Basic
import Quickshell
import Quickshell.Widgets
import Quickshell.Io

Item {
    id: launcherRoot
    signal closeRequested

    property bool isClipboardMode: false

    // ==========================================
    // 1. GLOBAL LAUNCH FUNCTIONS
    // ==========================================
    function launchApp(appModel) {
        if (appModel.runInTerminal) {
            let cmdArr = appModel.command || [];
            let baseCmd = cmdArr.length > 0 ? cmdArr[0] : appModel.name.toLowerCase();
            launcherRoot.pendingCommand = Config.terminalEmulator + " -e " + baseCmd;
            launcherRoot.closeRequested();
            execTimer.restart();
        } else {
            launcherRoot.pendingApp = appModel;
            launcherRoot.closeRequested();
            execTimer.restart();
        }
    }

    function copyClip(clipModel) {
        let safeLine = clipModel.rawLine.replace(/'/g, "'\\''");
        Quickshell.execDetached(["bash", "-c", "echo -E '" + safeLine + "' | cliphist decode | wl-copy"]);
        launcherRoot.closeRequested();
    }

    // ==========================================
    // 2. APP LAUNCH DELAY ENGINE
    // ==========================================
    property var pendingApp: null
    property string pendingCommand: ""

    Timer {
        id: execTimer
        interval: 350
        onTriggered: {
            if (launcherRoot.pendingApp) {
                launcherRoot.pendingApp.execute();
                launcherRoot.pendingApp = null;
            } else if (launcherRoot.pendingCommand !== "") {
                Quickshell.execDetached(["bash", "-c", launcherRoot.pendingCommand]);
                launcherRoot.pendingCommand = "";
            }
        }
    }

    // --- CLIPBOARD DATA ENGINE ---
    property var allClips: []
    property string clipBuffer: ""

    Process {
        id: clipProc
        command: ["bash", "-c", "cliphist list | head -n 50"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                launcherRoot.clipBuffer += data + "\n";
            }
        }
    }

    Connections {
        target: clipProc
        function onExited() {
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

    property int dynamicHeight: {
        let activeList = launcherRoot.isClipboardMode ? clipList : appList;
        let visibleItems = Math.min(activeList.count, Config.launcherMaxItems);

        let listHeight = visibleItems > 0 ? (visibleItems * (Config.appItemHeight + 6)) - 6 : 0;
        let baseHeight = Config.searchBarHeight + 56;

        return listHeight > 0 ? (baseHeight + listHeight) : baseHeight;
    }

    Timer {
        id: focusStealTimer
        interval: 100
        onTriggered: searchInput.forceActiveFocus()
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

    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        // --- THE SEARCH BAR ---
        Rectangle {
            id: searchBar
            width: parent.width
            height: Config.searchBarHeight
            radius: Config.searchBarRadius
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
                    font.family: Config.fontName
                    font.pixelSize: Config.fontSizeSearchIcon
                    color: searchInput.activeFocus ? (launcherRoot.isClipboardMode ? Colors.aqua : Colors.green) : Colors.fg2
                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }
                }

                TextField {
                    id: searchInput
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - (Config.fontSizeSearchIcon + 24) - (searchBar.showClear ? 40 : 0)
                    color: Colors.fg0
                    font.family: Config.fontName
                    font.pixelSize: Config.fontSizeSearchInput
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
                            if (activeList.currentIndex < activeList.count - 1) {
                                activeList.currentIndex++;
                            }
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Up) {
                            if (activeList.currentIndex > 0) {
                                activeList.currentIndex--;
                            }
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Escape) {
                            launcherRoot.closeRequested();
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
                                launcherRoot.closeRequested();
                                execTimer.restart();
                            }
                        }
                    }
                }
            }

            // --- THE INTEGRATED CLEAR ALL ICON ---
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
                    font.family: Config.fontName
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
                    onClicked: {
                        Quickshell.execDetached(["cliphist", "wipe"]);
                        launcherRoot.allClips = [];
                        searchInput.forceActiveFocus();
                    }
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
                    let search = searchInput.text.toLowerCase().trim();
                    let allApps = DesktopEntries.applications.values;

                    if (search === "")
                        return allApps;

                    return allApps.filter(app => {
                        if (app.name && app.name.toLowerCase().includes(search))
                            return true;
                        if (app.genericName && app.genericName.toLowerCase().includes(search))
                            return true;

                        if (app.keywords) {
                            for (let i = 0; i < app.keywords.length; i++) {
                                if (app.keywords[i].toLowerCase().includes(search))
                                    return true;
                            }
                        }
                        return false;
                    });
                }
            }

            delegate: Rectangle {
                id: delegateRect
                width: ListView.view.width
                height: Config.appItemHeight
                radius: Config.appItemRadius

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
                        appList.currentIndex = index;
                        launcherRoot.launchApp(modelData);
                    }
                }

                Row {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 16

                    IconImage {
                        anchors.verticalCenter: parent.verticalCenter
                        width: Config.appIconSize
                        height: Config.appIconSize
                        source: modelData.icon ? Quickshell.iconPath(modelData.icon) : ""
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.name || ""
                        color: delegateRect.isSelected ? Colors.green : Colors.fg0
                        font.family: Config.fontName
                        font.pixelSize: Config.fontSizeAppTitle
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
                    let search = searchInput.text.toLowerCase().trim();
                    if (search === "")
                        return triggerUpdate;

                    return triggerUpdate.filter(clip => clip.content.toLowerCase().includes(search));
                }
            }

            delegate: Rectangle {
                id: clipDelegateRect
                width: ListView.view.width
                height: Config.appItemHeight
                radius: Config.appItemRadius

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
                        clipList.currentIndex = index;
                        launcherRoot.copyClip(modelData);
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
                        font.family: Config.fontName
                        font.pixelSize: 18
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 110
                        text: modelData.content
                        color: clipDelegateRect.isSelected ? Colors.aqua : Colors.fg0
                        font.family: Config.fontName
                        font.pixelSize: Config.fontSizeAppTitle
                        elide: Text.ElideRight
                    }
                }

                // QUICK ACTION ICONS (COPY & DELETE)
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
                            font.family: Config.fontName
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
                                let safeLine = modelData.rawLine.replace(/'/g, "'\\''");
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
                            font.family: Config.fontName
                            font.pixelSize: 16
                        }

                        MouseArea {
                            id: delHoverArea
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: {
                                let safeLine = modelData.rawLine.replace(/'/g, "'\\''");
                                Quickshell.execDetached(["bash", "-c", "echo -E '" + safeLine + "' | cliphist delete"]);
                                launcherRoot.allClips = launcherRoot.allClips.filter(c => c.clipId !== modelData.clipId);
                                searchInput.forceActiveFocus();
                            }
                        }
                    }
                }
            }
        }
    }
}
