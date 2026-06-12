import QtQuick
import Quickshell.Io

Item {
    id: bindsRoot

    // Links this file to your PillWindow
    property var target: null

    IpcHandler {
        // This is the namespace you will call from the Hyprland CLI
        target: "mediaPill"

        // 1. IPC Listener for the Dashboard
        function toggleTime(): void {
            if (bindsRoot.target) {
                bindsRoot.target.viewState = (bindsRoot.target.viewState === 1) ? 0 : 1;
            }
        }

        // 2. IPC Listener for the Media Controller
        function toggleMedia(): void {
            if (bindsRoot.target) {
                // If it's open, go back to dashboard. If it's closed/dashboard, open media.
                bindsRoot.target.viewState = (bindsRoot.target.viewState === 3) ? 1 : 3;
            }
        }

        // --- NEW: IPC Command for Power Menu ---
        function togglePowerMenu(): void {
            if (bindsRoot.target) {
                bindsRoot.target.viewState = (bindsRoot.target.viewState === 4) ? 0 : 4;
            }
        }

        // 3. IPC Listener for Global Close
        function closePill(): void {
            if (bindsRoot.target) {
                bindsRoot.target.viewState = 0;
            }
        }
    }
}
