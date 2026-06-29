import QtQuick
import Quickshell.Io

Item {
    id: bindsRoot

    property var launcherTarget: null

    IpcHandler {
        target: "bar"

        function toggleLauncher(): void {
            if (bindsRoot.launcherTarget) {
                bindsRoot.launcherTarget.visible = !bindsRoot.launcherTarget.visible;
                if (bindsRoot.launcherTarget.visible)
                    bindsRoot.launcherTarget.isClipboardMode = false;
            }
        }

        function toggleClipboard(): void {
            if (bindsRoot.launcherTarget) {
                bindsRoot.launcherTarget.visible = !bindsRoot.launcherTarget.visible;
                if (bindsRoot.launcherTarget.visible)
                    bindsRoot.launcherTarget.isClipboardMode = true;
            }
        }

        function closeAll(): void {
            if (bindsRoot.launcherTarget) {
                bindsRoot.launcherTarget.visible = false;
            }
        }
    }
}
