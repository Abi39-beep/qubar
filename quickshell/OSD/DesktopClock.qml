import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "."

PanelWindow {
    id: clockRoot

    property bool isOsdOpen: false
    property bool hasWindows: false

    anchors {
        top: true
        right: true
    }

    margins {
        top: 50
        right: 50
    }

    // FIX 1: Give the PanelWindow a physical size so Wayland knows how to draw it!
    implicitWidth: clockContainer.implicitWidth
    implicitHeight: clockContainer.implicitHeight

    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    
    // FIX 2: WlrLayer.Bottom sits ON TOP of the wallpaper, but behind normal windows.
    // (WlrLayer.Background gets completely hidden by Hyprpaper/Swaybg!)
    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: {
            windowCheck.running = true
        }
    }

    Process {
        id: windowCheck
        command:[
            "bash",
            "-c",
            "hyprctl activeworkspace | awk '/windows:/ {print $2}'"
        ]
        stdout: SplitParser {
            onRead: data => {
                let count = parseInt(data.trim())
                if (!isNaN(count)) {
                    clockRoot.hasWindows = (count > 0)
                }
            }
        }
    }

    Item {
        id: clockContainer
        
        // Let the container dynamically size itself based on the text size
        implicitWidth: Math.max(timeText.implicitWidth, dateText.implicitWidth)
        implicitHeight: timeText.implicitHeight + 5 + dateText.implicitHeight
        
        opacity: (!clockRoot.hasWindows && !clockRoot.isOsdOpen) ? 1.0 : 0.0
        
        Behavior on opacity {
            NumberAnimation {
                duration: 300
            }
        }
        
        Text {
            id: timeText
            anchors.top: parent.top
            anchors.right: parent.right
            text: Qt.formatDateTime(new Date(), "hh:mm AP")
            color: Colors.fg
            font.pixelSize: 72
            font.bold: true
            font.family: "JetBrainsMono Nerd Font"
            
            // Gives it a subtle shadow so it pops perfectly against bright wallpapers
            style: Text.Outline
            styleColor: "#80000000"
        }
        
        Text {
            id: dateText
            anchors.top: timeText.bottom
            anchors.topMargin: 5
            anchors.right: parent.right
            text: Qt.formatDateTime(new Date(), "dddd, MMMM d")
            color: Colors.blue
            font.pixelSize: 24
            font.bold: true
            font.family: "JetBrainsMono Nerd Font"
            
            style: Text.Outline
            styleColor: "#80000000"
        }

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: {
                let now = new Date()
                timeText.text = Qt.formatDateTime(now, "hh:mm AP")
                dateText.text = Qt.formatDateTime(now, "dddd, MMMM d")
            }
        }
    }
}
