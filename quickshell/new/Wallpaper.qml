import QtQuick
import Quickshell
import Qt.labs.folderlistmodel

Item {
    id: wallEngine

    property string targetTheme: ""
    property bool wantsRandom: false
    property bool pendingRestart: false

    Timer {
        id: fallbackRestartTimer
        interval: 1000
        running: false
        onTriggered: {
            if (wallEngine.pendingRestart) {
                wallEngine.pendingRestart = false;
                wallEngine.triggerRestart();
            }
        }
    }

    FolderListModel {
        id: randomModel
        folder: wallEngine.targetTheme !== "" ? ("file://" + Quickshell.env("HOME") + "/.config/quickshell/themes/" + wallEngine.targetTheme) : ""
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp", "*.JPG", "*.JPEG", "*.PNG", "*.WEBP"]
        caseSensitive: false
        showDirs: false

        onStatusChanged: {
            if (status === FolderListModel.Ready && wallEngine.wantsRandom) {
                wallEngine.wantsRandom = false;
                if (count > 0) {
                    let randomIndex = Math.floor(Math.random() * count);
                    let randomPath = get(randomIndex, "filePath").toString();
                    wallEngine.apply(randomPath);
                } else if (wallEngine.pendingRestart) {
                    wallEngine.pendingRestart = false;
                    fallbackRestartTimer.stop();
                    wallEngine.triggerRestart();
                }
            }
        }
    }

    function apply(path) {
        if (!path) {
            if (wallEngine.pendingRestart) {
                wallEngine.pendingRestart = false;
                fallbackRestartTimer.stop();
                wallEngine.triggerRestart();
            }
            return;
        }

        let cleanPath = path.toString().replace("file://", "");
        let home = Quickshell.env("HOME");

        Quickshell.execDetached(["bash", "-c", `echo "${cleanPath}" > "${home}/.cache/current_wallpaper"`]);

        if (wallEngine.pendingRestart) {
            wallEngine.pendingRestart = false;
            fallbackRestartTimer.stop();
            wallEngine.triggerRestart();
        }
    }

    function applyRandom(themeName, triggerRestartAfter) {
        wallEngine.wantsRandom = true;
        wallEngine.pendingRestart = triggerRestartAfter === true;

        if (wallEngine.pendingRestart)
            fallbackRestartTimer.restart();

        if (wallEngine.targetTheme === themeName && randomModel.status === FolderListModel.Ready) {
            wallEngine.wantsRandom = false;
            if (randomModel.count > 0) {
                let randomIndex = Math.floor(Math.random() * randomModel.count);
                let randomPath = randomModel.get(randomIndex, "filePath").toString();
                wallEngine.apply(randomPath);
            } else if (wallEngine.pendingRestart) {
                wallEngine.pendingRestart = false;
                fallbackRestartTimer.stop();
                wallEngine.triggerRestart();
            }
        } else {
            wallEngine.targetTheme = themeName;
        }
    }

    function triggerRestart() {
        let home = Quickshell.env("HOME");
        let reloadCmd = `sleep 0.2 && if [ -f "${home}/.config/quickshell/reload.sh" ]; then bash "${home}/.config/quickshell/reload.sh" & else killall quickshell && quickshell & fi`;
        Quickshell.execDetached(["bash", "-c", reloadCmd]);
    }
}
