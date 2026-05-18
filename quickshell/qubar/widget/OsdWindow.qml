import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import ".."

PanelWindow {
    id: osdRoot
    
    // Tell Wayland to stick this to the bottom center of the screen
    anchors.bottom: true

    width: 240
    
    // FIX: We make the invisible window 130px tall (50px for the UI + 80px for the gap)
    height: 130 

    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    visible: osdOpacity > 0
    
    property real osdOpacity: 0
    Behavior on osdOpacity { NumberAnimation { duration: 150 } }

    property bool isReady: false
    Timer { interval: 1000; running: true; onTriggered: isReady = true }

    Timer {
        id: hideTimer
        interval: 2000 
        onTriggered: osdRoot.osdOpacity = 0
    }

    property int currentMode: 0

    function showOsd(mode) {
        if (!isReady) return;
        currentMode = mode;
        osdRoot.osdOpacity = 1;
        hideTimer.restart();
    }

    // ==========================================
    // VOLUME TRACKING
    // ==========================================
    PwObjectTracker {
        objects: Pipewire.defaultAudioSink ?[Pipewire.defaultAudioSink] :[]
    }
    property var audio: Pipewire.defaultAudioSink?.audio
    property int volPercent: audio ? Math.round(audio.volume * 100) : 0
    property bool isMuted: audio ? audio.muted : false

    onVolPercentChanged: showOsd(0)
    onIsMutedChanged: showOsd(0)

    // ==========================================
    // BRIGHTNESS TRACKING
    // ==========================================
    property int briPercent: 50

    Process {
        id: getBri
        command:["brightnessctl", "-m"]
        stdout: SplitParser {
            onRead: data => {
                let parts = data.split(",");
                if (parts.length >= 4) {
                    let newBri = parseInt(parts[3].replace("%", ""));
                    if (briPercent !== newBri) {
                        briPercent = newBri;
                        showOsd(1); 
                    }
                }
            }
        }
    }

    Process {
        command:["stdbuf", "-oL", "udevadm", "monitor", "--subsystem-match=backlight"]
        running: true
        stdout: SplitParser {
            onRead: data => { getBri.running = true; }
        }
    }

    Component.onCompleted: getBri.running = true

    // ==========================================
    // THE OSD UI (Sleek Pill Shape)
    // ==========================================
    Rectangle {
        // FIX: We align this to the TOP of our 130px invisible window.
        // This leaves the 80px gap at the bottom perfectly intact!
        anchors.top: parent.top
        width: parent.width
        height: 50
        
        opacity: osdRoot.osdOpacity
        
        color: Colors.bg0
        border.color: Colors.bg2
        border.width: 1
        radius: 25 

        Row {
            anchors.centerIn: parent
            spacing: 15

            // Dynamic Icon
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: {
                    if (currentMode === 0) return osdRoot.isMuted ? "󰝟" : (osdRoot.volPercent > 50 ? "󰕾" : (osdRoot.volPercent > 0 ? "󰖀" : "󰕿"));
                    return "󰃠";
                }
                color: {
                    if (currentMode === 0) return osdRoot.isMuted ? Colors.red : Colors.blue;
                    return Colors.orange;
                }
                font.pixelSize: 20
                font.family: "JetBrainsMono Nerd Font"
            }

            // Progress Bar
            Rectangle {
                width: 130
                height: 6
                radius: 3
                color: Colors.bg2
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    height: parent.height
                    radius: 3
                    width: parent.width * ((osdRoot.currentMode === 0 ? osdRoot.volPercent : osdRoot.briPercent) / 100.0)
                    color: osdRoot.currentMode === 0 ? Colors.blue : Colors.green
                    
                    Behavior on width { NumberAnimation { duration: 100; easing.type: Easing.OutQuad } }
                }
            }

            // Percentage Text
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: (osdRoot.currentMode === 0 ? osdRoot.volPercent : osdRoot.briPercent) + "%"
                color: Colors.fg
                font.pixelSize: 13
                font.bold: true
                font.family: "JetBrainsMono Nerd Font"
                width: 35 
                horizontalAlignment: Text.AlignRight
            }
        }
    }
}
