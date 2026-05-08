import QtQuick
import Quickshell
import Quickshell.Hyprland
import "."

Rectangle {
    id: activeWindowPill
    
    property var activeWin: Hyprland.activeToplevel
    
    // NEW FIX: Physically check if the workspace you are currently looking at has any windows!
    property bool isWorkspaceOccupied: Hyprland.focusedWorkspace ? (Hyprland.focusedWorkspace.toplevels.values.length > 0) : false
    
    // Now it requires BOTH a valid title AND an occupied workspace to show itself
    property bool hasWindow: isWorkspaceOccupied && !!activeWin && activeWin.title !== ""
    
    // Dynamically resize based on text length, shrink to 0 when empty
    width: hasWindow ? Math.min(400, windowText.implicitWidth + 30) : 0
    height: 30
    radius: 15
    color: Colors.bg1
    
    // Completely hide the border when width is 0 so it leaves no ghost lines
    border.width: hasWindow ? 1 : 0
    border.color: Colors.bg2
    clip: true

    // Smooth sliding animation when switching windows
    Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutExpo } }

    Text {
        id: windowText
        anchors.centerIn: parent
        
        // Safely fetch the title only if we confirmed there is a window
        text: (activeWindowPill.hasWindow && activeWindowPill.activeWin) ? activeWindowPill.activeWin.title : ""
        color: Colors.fg
        font.pixelSize: 13
        font.bold: true
        
        // Caps the max width so long website titles don't stretch across your whole screen
        width: Math.min(implicitWidth, 370)
        elide: Text.ElideRight
        
        // Smoothly fade out the text when the widget shrinks
        opacity: activeWindowPill.hasWindow ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }
}
