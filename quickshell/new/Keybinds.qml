import QtQuick
import Quickshell.Hyprland

// qmllint disable import
Item {
    id: bindsRoot

    property var launcherTarget: null
    property var controlCenterTarget: null

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

    GlobalShortcut {
        name: "toggle_control_center"
        description: "Open Quickshell Control Center"

        onPressed: {
            if (bindsRoot.controlCenterTarget) {
                bindsRoot.controlCenterTarget.visible = !bindsRoot.controlCenterTarget.visible;
            }
        }
    }

    GlobalShortcut {
        name: "toggle_power_menu"
        description: "Open Quickshell Power Menu Directly"

        onPressed: {
            if (bindsRoot.controlCenterTarget) {
                if (bindsRoot.controlCenterTarget.visible && bindsRoot.controlCenterTarget.currentView === "power") {
                    bindsRoot.controlCenterTarget.visible = false;
                } else {
                    bindsRoot.controlCenterTarget.visible = true;
                    bindsRoot.controlCenterTarget.currentView = "power";
                }
            }
        }
    }

    GlobalShortcut {
        name: "close_all"
        description: "Close all Quickshell Overlays"

        onPressed: {
            if (bindsRoot.launcherTarget) {
                bindsRoot.launcherTarget.visible = false;
            }
            if (bindsRoot.controlCenterTarget) {
                bindsRoot.controlCenterTarget.visible = false;
            }
        }
    }
}
