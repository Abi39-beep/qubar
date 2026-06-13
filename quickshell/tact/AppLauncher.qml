import QtQuick
import QtQuick.Controls.Basic
import Quickshell
import Quickshell.Widgets

Item {
    id: launcherRoot
    signal closeRequested

    // --- SMART CONFIG-DRIVEN HEIGHT MATH ---
    property int dynamicHeight: {
        let visibleItems = Math.min(appList.count, Config.launcherMaxItems);

        // Item height + 6px spacing between items
        let listHeight = visibleItems > 0 ? (visibleItems * (Config.appItemHeight + 6)) - 6 : 0;

        // 56px = 20px top margin + 16px column spacing + 20px bottom margin
        let baseHeight = Config.searchBarHeight + 56;

        return listHeight > 0 ? (baseHeight + listHeight) : baseHeight;
    }

    onVisibleChanged: {
        if (visible) {
            searchInput.text = "";
            searchInput.forceActiveFocus();
            appList.contentY = 0;
            appList.currentIndex = 0;
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
            border.color: searchInput.activeFocus ? Colors.green : Colors.bg3
            border.width: 2

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
                    text: ""
                    font.family: Config.fontName
                    font.pixelSize: Config.fontSizeSearchIcon
                    color: searchInput.activeFocus ? Colors.green : Colors.fg2
                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }
                }

                TextField {
                    id: searchInput
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - (Config.fontSizeSearchIcon + 20)
                    color: Colors.fg0
                    font.family: Config.fontName
                    font.pixelSize: Config.fontSizeSearchInput
                    background: null
                    placeholderText: "Search apps or run command..."
                    placeholderTextColor: Colors.bg4

                    onTextChanged: appList.currentIndex = 0

                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Down) {
                            if (appList.currentIndex < appList.count - 1) {
                                appList.currentIndex++;
                            }
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Up) {
                            if (appList.currentIndex > 0) {
                                appList.currentIndex--;
                            }
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Escape) {
                            launcherRoot.closeRequested();
                            event.accepted = true;
                        }
                    }

                    onAccepted: {
                        if (appList.count > 0 && appList.currentIndex >= 0) {
                            appList.currentItem.trigger();
                        } else if (text.trim() !== "") {
                            // Raw text typed in the bar uses Bash
                            Quickshell.execDetached(["bash", "-c", text.trim()]);
                            launcherRoot.closeRequested();
                        }
                    }
                }
            }
        }

        // --- THE DYNAMIC NATIVE APP LIST ---
        ListView {
            id: appList
            width: parent.width
            height: parent.height - searchBar.height - 16
            clip: true
            spacing: 6

            highlightFollowsCurrentItem: true
            currentIndex: 0

            model: ScriptModel {
                objectProp: "id"

                values: {
                    let search = searchInput.text.toLowerCase().trim();
                    let allApps = DesktopEntries.applications.values;

                    if (search === "") {
                        return allApps;
                    }

                    return allApps.filter(function (app) {
                        return app.name && app.name.toLowerCase().includes(search);
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

                // --- THE PROVEN WORKING TRIGGER RESTORED ---
                function trigger() {
                    let appName = modelData.name.toLowerCase();

                    // Add any other specific terminal apps you use to this list!
                    let cliApps = ["htop", "btop", "yazi", "ranger", "lf", "cava", "ncmpcpp", "nvtop", "pulsemixer"];
                    let cliMatch = "";

                    // Check if the app name contains any of your known terminal apps
                    for (let i = 0; i < cliApps.length; i++) {
                        if (appName.includes(cliApps[i])) {
                            cliMatch = cliApps[i];
                            break;
                        }
                    }

                    if (cliMatch !== "") {
                        // 1. Forcefully open known CLI apps natively using Config terminal!
                        Quickshell.execDetached([Config.terminalEmulator, "-e", cliMatch]);
                    } else {
                        // 2. Normal GUI apps use Quickshell's native, guaranteed launcher
                        modelData.execute();
                    }

                    launcherRoot.closeRequested();
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
                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }
                    }
                }

                MouseArea {
                    id: appArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        appList.currentIndex = index;
                        delegateRect.trigger();
                    }
                }
            }
        }
    }
}
