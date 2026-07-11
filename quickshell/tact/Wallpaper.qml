import QtQuick
import Quickshell
import Qt.labs.folderlistmodel

Item {
    id: wallEngine

    property string targetTheme: ""
    property bool wantsRandom: false
    property bool pendingRestart: false

    property string homeDir: Quickshell.env("HOME")
    property string cachePath: homeDir + "/.cache/current_wallpaper"

    Timer {
        id: fallbackRestartTimer
        interval: 1000
        running: false
        onTriggered: wallEngine.checkAndRestart()
    }

    FolderListModel {
        id: randomModel
        folder: wallEngine.targetTheme !== "" ? "file://" + wallEngine.homeDir + "/.config/quickshell/themes/" + wallEngine.targetTheme : ""
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp"]
        caseSensitive: false
        showDirs: false

        onStatusChanged: {
            if (status === FolderListModel.Ready && wallEngine.wantsRandom) {
                wallEngine.wantsRandom = false;
                wallEngine.pickRandomAndApply();
            }
        }
    }

    // Helper to dry up the random selection logic
    function pickRandomAndApply() {
        if (randomModel.count > 0) {
            const idx = Math.floor(Math.random() * randomModel.count);
            const path = randomModel.get(idx, "filePath").toString();
            wallEngine.apply(path);
        } else {
            wallEngine.checkAndRestart();
        }
    }

    // Helper to keep restart logic DRY
    function checkAndRestart() {
        if (wallEngine.pendingRestart) {
            wallEngine.pendingRestart = false;
            fallbackRestartTimer.stop();
            wallEngine.triggerRestart();
        }
    }

    function apply(path) {
        if (!path) {
            wallEngine.checkAndRestart();
            return;
        }

        Quickshell.execDetached(["sh", "-c", 'printf "%s\n" "$1" > "$2"', "--", path.toString(), wallEngine.cachePath]);

        wallEngine.checkAndRestart();
    }

    function applyRandom(themeName, triggerRestartAfter) {
        wallEngine.wantsRandom = true;
        wallEngine.pendingRestart = (triggerRestartAfter === true);

        if (wallEngine.pendingRestart) {
            fallbackRestartTimer.restart();
        }

        if (wallEngine.targetTheme === themeName && randomModel.status === FolderListModel.Ready) {
            wallEngine.wantsRandom = false;
            wallEngine.pickRandomAndApply();
        } else {
            wallEngine.targetTheme = themeName;
        }
    }

    function triggerRestart() {
        const reloadScript = wallEngine.homeDir + "/.config/quickshell/reload.sh";
        const cmd = 'sleep 0.2 && if [ -f "$1" ]; then bash "$1" & else killall quickshell && quickshell & fi';

        Quickshell.execDetached(["sh", "-c", cmd, "--", reloadScript]);
    }
}
