import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
    LockScreen {
        id: systemLockScreen
    }

    IpcHandler {
        target: "syslock"
        function lock(): void {
            systemLockScreen.isLocked = true;
        }
    }
}
