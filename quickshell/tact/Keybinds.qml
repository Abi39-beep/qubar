import QtQuick
import Quickshell.Io

Item {
    id: bindsRoot
    property var target: null

    IpcHandler {
        target: "mediaPill"

        function toggleTime(): void {
            if (bindsRoot.target)
                bindsRoot.target.viewState = (bindsRoot.target.viewState === 1) ? 0 : 1;
        }

        function toggleMedia(): void {
            if (bindsRoot.target)
                bindsRoot.target.viewState = (bindsRoot.target.viewState === 3) ? 1 : 3;
        }

        function togglePowerMenu(): void {
            if (bindsRoot.target)
                bindsRoot.target.viewState = (bindsRoot.target.viewState === 4) ? 0 : 4;
        }

        function toggleLauncher(): void {
            if (bindsRoot.target)
                bindsRoot.target.viewState = (bindsRoot.target.viewState === 5) ? 0 : 5;
        }

        function toggleControlCenter(): void {
            if (bindsRoot.target) {
                if (bindsRoot.target.viewState === 7 && bindsRoot.target.cc.currentView === 0) {
                    bindsRoot.target.viewState = 0;
                } else {
                    bindsRoot.target.viewState = 7;
                    bindsRoot.target.cc.currentView = 0;
                }
            }
        }

        function toggleSettings(): void {
            if (bindsRoot.target) {
                if (bindsRoot.target.viewState === 7 && bindsRoot.target.cc.currentView === 3) {
                    bindsRoot.target.viewState = 0;
                } else {
                    bindsRoot.target.viewState = 7;
                    bindsRoot.target.cc.currentView = 3;
                }
            }
        }

        function toggleTheme(): void {
            if (bindsRoot.target) {
                if (bindsRoot.target.viewState === 7 && bindsRoot.target.cc.currentView === 4) {
                    bindsRoot.target.viewState = 0;
                } else {
                    bindsRoot.target.viewState = 7;
                    bindsRoot.target.cc.currentView = 4;
                }
            }
        }

        function toggleWallpaper(): void {
            if (bindsRoot.target) {
                if (bindsRoot.target.viewState === 7 && bindsRoot.target.cc.currentView === 5) {
                    bindsRoot.target.viewState = 0; // Close it if it's already open
                } else {
                    bindsRoot.target.viewState = 7; // Open Control Center
                    bindsRoot.target.cc.currentView = 5; // Jump to Wallpapers
                }
            }
        }

        function closePill(): void {
            if (bindsRoot.target)
                bindsRoot.target.viewState = 0;
        }
    }
}
