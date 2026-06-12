import QtQuick
import QtQuick.Controls.Basic
import Quickshell
import Quickshell.Widgets

Item {
    id: launcherRoot
    signal closeRequested

    // --- TERMINAL FIX ---
    // Change this if you use alacritty, wezterm, or foot instead of kitty!
    property string terminalEmulator: "kitty"

    // --- SMART HEIGHT MATH ---
    // 50px (search bar) + 40px (margins/spacing) = 90px base height.
    // Each app is 54px + 6px spacing = 60px. We cap it at 6 apps max!
    property int dynamicHeight: {
        let visibleItems = Math.min(appList.count, 6);
        let listHeight = visibleItems > 0 ? (visibleItems * 60) - 6 : 0;
        return listHeight > 0 ? (90 + listHeight + 16) : 90;
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
            height: 50
            radius: 12
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
                    font.pixelSize: 20
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
                    width: parent.width - 40
                    color: Colors.fg0
                    font.family: Config.fontName
                    font.pixelSize: 20
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
                            // Grabs the selected item from the delegate directly to use the Smart Trigger
                            appList.currentItem.trigger();
                        } else if (text.trim() !== "") {
                            Quickshell.execDetached(["bash", "-c", text]);
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
                height: 54
                radius: 12

                property bool isSelected: ListView.isCurrentItem || appArea.containsMouse

                color: isSelected ? Colors.bg2 : "transparent"
                border.color: isSelected ? Colors.bg3 : "transparent"
                border.width: 2

                // --- THE FOOLPROOF TERMINAL INTERCEPTOR ---
                function trigger() {
                    if (modelData.terminal) {
                        // 1. Get the command
                        let rawExec = modelData.exec || modelData.name.toLowerCase();

                        // 2. Remove desktop file flags (like %U, %f, etc) that break terminal args
                        let cleanExec = String(rawExec).replace(/%[a-zA-Z]/g, "").trim();

                        // 3. Force absolute paths and full shell invocation
                        // We use /bin/sh to ensure the environment is correctly loaded for Kitty
                        let terminalPath = "/usr/bin/" + launcherRoot.terminalEmulator;
                        let finalCmd = terminalPath + " -e /bin/sh -c '" + cleanExec + "'";

                        Quickshell.execDetached(["/bin/sh", "-c", finalCmd]);
                    } else {
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
                        width: 30
                        height: 30
                        source: modelData.icon ? Quickshell.iconPath(modelData.icon) : ""
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.name || ""
                        color: delegateRect.isSelected ? Colors.green : Colors.fg0
                        font.family: Config.fontName
                        font.pixelSize: 18
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
