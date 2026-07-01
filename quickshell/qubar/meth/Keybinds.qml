import QtQuick
import Quickshell.Hyprland

Item {
    id: bindsRoot

    property var launcherTarget: null

    GlobalShortcut {
        name: "toggle_launcher"
        description: "Open Quickshell App Launcher"

        onPressed: {
            if (bindsRoot.launcherTarget) {
                bindsRoot.launcherTarget.visible = !bindsRoot.launcherTarget.visible;
                if (bindsRoot.launcherTarget.visible)
                    bindsRoot.launcherTarget.isClipboardMode = false;
            }
        }
    }

    GlobalShortcut {
        name: "toggle_clipboard"
        description: "Open Quickshell Clipboard"

        onPressed: {
            if (bindsRoot.launcherTarget) {
                bindsRoot.launcherTarget.visible = !bindsRoot.launcherTarget.visible;
                if (bindsRoot.launcherTarget.visible)
                    bindsRoot.launcherTarget.isClipboardMode = true;
            }
        }
    }

    // qmllint disable import
    GlobalShortcut {
        name: "close_all"
        description: "Close all Quickshell Overlays"

        onPressed: {
            if (bindsRoot.launcherTarget) {
                bindsRoot.launcherTarget.visible = false;
            }
        }
    }
}
