import QtQuick
import Quickshell.Hyprland

// qmllint disable import
Item {
    id: bindsRoot
    property var target: null

    GlobalShortcut {
        name: "toggle_time"
        description: "Toggle Time View"
        onPressed: {
            if (bindsRoot.target)
                bindsRoot.target.viewState = (bindsRoot.target.viewState === 1) ? 0 : 1;
        }
    }

    GlobalShortcut {
        name: "toggle_media"
        description: "Toggle Media View"
        onPressed: {
            if (bindsRoot.target)
                bindsRoot.target.viewState = (bindsRoot.target.viewState === 3) ? 1 : 3;
        }
    }

    GlobalShortcut {
        name: "toggle_power_menu"
        description: "Toggle Power Menu"
        onPressed: {
            if (bindsRoot.target)
                bindsRoot.target.viewState = (bindsRoot.target.viewState === 4) ? 0 : 4;
        }
    }

    GlobalShortcut {
        name: "toggle_launcher"
        description: "Toggle Launcher"
        onPressed: {
            if (bindsRoot.target)
                bindsRoot.target.viewState = (bindsRoot.target.viewState === 5) ? 0 : 5;
        }
    }

    GlobalShortcut {
        name: "toggle_control_center"
        description: "Toggle Control Center"
        onPressed: {
            if (bindsRoot.target) {
                if (bindsRoot.target.viewState === 7 && bindsRoot.target.cc.currentView === 0) {
                    bindsRoot.target.viewState = 0;
                } else {
                    bindsRoot.target.viewState = 7;
                    bindsRoot.target.cc.currentView = 0;
                }
            }
        }
    }

    GlobalShortcut {
        name: "toggle_settings_menu"
        description: "Toggle Settings Menu"
        onPressed: {
            if (bindsRoot.target) {
                if (bindsRoot.target.viewState === 7 && bindsRoot.target.cc.currentView === 3) {
                    bindsRoot.target.viewState = 0;
                } else {
                    bindsRoot.target.viewState = 7;
                    bindsRoot.target.cc.currentView = 3;
                }
            }
        }
    }

    GlobalShortcut {
        name: "toggle_theme_menu"
        description: "Toggle Theme Menu"
        onPressed: {
            if (bindsRoot.target) {
                if (bindsRoot.target.viewState === 7 && bindsRoot.target.cc.currentView === 4) {
                    bindsRoot.target.viewState = 0;
                } else {
                    bindsRoot.target.viewState = 7;
                    bindsRoot.target.cc.currentView = 4;
                }
            }
        }
    }

    GlobalShortcut {
        name: "toggle_wallpaper_menu"
        description: "Toggle Wallpaper Menu"
        onPressed: {
            if (bindsRoot.target) {
                if (bindsRoot.target.viewState === 7 && bindsRoot.target.cc.currentView === 5) {
                    bindsRoot.target.viewState = 0;
                } else {
                    bindsRoot.target.viewState = 7;
                    bindsRoot.target.cc.currentView = 5;
                }
            }
        }
    }

    GlobalShortcut {
        name: "toggle_bar_menu"
        description: "Toggle Bar Layouts Menu"
        onPressed: {
            if (bindsRoot.target) {
                if (bindsRoot.target.viewState === 7 && bindsRoot.target.cc.currentView === 7) {
                    bindsRoot.target.viewState = 0;
                } else {
                    bindsRoot.target.viewState = 7;
                    bindsRoot.target.cc.currentView = 7;
                }
            }
        }
    }

    GlobalShortcut {
        name: "close_all"
        description: "Close all Quickshell Overlays"
        onPressed: {
            if (bindsRoot.target)
                bindsRoot.target.viewState = 0;
        }
    }
}
