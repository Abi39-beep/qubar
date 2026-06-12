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

        // --- NEW: App Launcher Command ---
        function toggleLauncher(): void {
            if (bindsRoot.target)
                bindsRoot.target.viewState = (bindsRoot.target.viewState === 5) ? 0 : 5;
        }

        function closePill(): void {
            if (bindsRoot.target)
                bindsRoot.target.viewState = 0;
        }
    }
}
