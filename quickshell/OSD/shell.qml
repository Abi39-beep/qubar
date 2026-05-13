import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import "."

ShellRoot {
    id: root

    LeftOSD {
        id: leftSide
    }

    RightOSD {
        id: rightSide
    }

    PowerMenu {
        id: powerMenu
    }
    
    OsdWindow {
        id: bottomOsd
    }

    DesktopClock {
        id: windowCheck
    }

    GlobalShortcut {
        name: "powermenu" 
        onPressed: {
            if (!powerMenu.visible) {
                powerMenu.openMenu()
            } else {
                powerMenu.closeMenu()
            }
        }
    }

    IpcHandler {
        target: "osd"
        
        function toggleLeft(): void { 
            leftSide.toggleLeft() 
        }
        
        function toggleRight(): void { 
            rightSide.toggleRight() 
        }
        
        function togglePower(): void {
            if (!powerMenu.visible) {
                powerMenu.openMenu()
            } else {
                powerMenu.closeMenu()
            }
        }
    }
}
