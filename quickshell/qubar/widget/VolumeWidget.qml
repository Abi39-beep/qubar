import QtQuick
import QtQuick.Controls 
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import ".."

Rectangle {
    id: volWidget
    width: 30; height: 30; radius: 15
    color: Colors.bg1 
    border.width: 1
    border.color: Colors.bg2

    // --- VOLUME TRACKING ---
    // FIX 1: PwObjectTracker explicitly tells Quickshell to listen to Pipewire live!
    // Without this, the volume percentage will permanently freeze.
    PwObjectTracker {
        objects: Pipewire.defaultAudioSink ?[ Pipewire.defaultAudioSink ] :[]
    }

    property var audio: Pipewire.defaultAudioSink?.audio
    property int volPercent: audio ? Math.round(audio.volume * 100) : 0
    property bool isMuted: audio ? audio.muted : false

    // --- BRIGHTNESS TRACKING ---
    property int briPercent: 50 

    Timer {
        interval: 2000; running: true; repeat: true
        onTriggered: getBri.running = true
        Component.onCompleted: getBri.running = true 
    }

    Process {
        id: getBri
        command: ["brightnessctl", "-m"]
        stdout: SplitParser {
            onRead: data => {
                let parts = data.split(",");
                if (parts.length >= 4) {
                    volWidget.briPercent = parseInt(parts[3].replace("%", ""));
                }
            }
        }
    }

    // --- BAR ICON ---
    Text {
        anchors.centerIn: parent
        text: volWidget.isMuted ? "󰝟" : (volWidget.volPercent > 50 ? "󰕾" : (volWidget.volPercent > 0 ? "󰖀" : "󰕿"))
        font.pixelSize: 15
        font.family: "JetBrainsMono Nerd Font"
        color: volWidget.isMuted ? Colors.red : Colors.fg 
    }

    // Wheel scrolling on the TOP BAR icon
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: volPopup.visible = !volPopup.visible
        
        onWheel: (wheel) => {
            let newVol = volWidget.volPercent + (wheel.angleDelta.y > 0 ? 5 : -5);
            newVol = Math.max(0, Math.min(100, newVol));
            
            // Instantly updates UI
            if (audio) audio.volume = newVol / 100.0;
            // Failsafe: Forces the OS to change it via WirePlumber
            Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", (newVol / 100.0).toFixed(2)]);
        }
    }

    // --- POPUP WINDOW ---
    PopupWindow {
        id: volPopup
        anchor.item: volWidget
        anchor.edges: Edges.Bottom | Edges.Left
        width: 250; height: 160 
        visible: false
        color: "transparent"
        grabFocus: true 
        
        onVisibleChanged: { if (visible) bgRect.forceActiveFocus() }

        Rectangle {
            id: bgRect
            anchors.fill: parent; anchors.topMargin: 10
            color: Qt.alpha(Colors.bg0, 0.95); border.color: Colors.bg2; border.width: 1; radius: 8
            focus: true
            Keys.onEscapePressed: volPopup.visible = false
            onActiveFocusChanged: { if (!activeFocus) volPopup.visible = false }

            Column {
                anchors.fill: parent; anchors.margins: 15; spacing: 20

                // ==========================
                // 1. VOLUME SECTION
                // ==========================
                Item {
                    width: parent.width; height: 45

                    Item {
                        width: parent.width; height: 20
                        
                        Row {
                            anchors.left: parent.left; spacing: 8
                            Text { text: volWidget.isMuted ? "󰝟" : "󰕾"; color: Colors.blue; font.pixelSize: 14; font.family: "JetBrainsMono Nerd Font"; anchors.verticalCenter: parent.verticalCenter }
                            Text { text: "Volume"; color: Colors.blue; font.pixelSize: 13; font.family: "JetBrainsMono Nerd Font"; anchors.verticalCenter: parent.verticalCenter }
                        }
                        Text { anchors.right: parent.right; text: volWidget.volPercent + "%"; color: Colors.blue; font.pixelSize: 13; font.family: "JetBrainsMono Nerd Font" }
                    }

                    Slider {
                        id: volSlider
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 24 
                        from: 0; to: 100
                        
                        focusPolicy: Qt.NoFocus 
                        
                        Binding {
                            target: volSlider
                            property: "value"
                            value: volWidget.volPercent
                            when: !volSlider.pressed
                        }
                        
                        onValueChanged: {
                            if (pressed) {
                                // Instantly updates UI
                                if (volWidget.audio) volWidget.audio.volume = value / 100.0;
                                // Failsafe: Forces the OS to change it via WirePlumber
                                Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", (value / 100.0).toFixed(2)]);
                            }
                        }

                        // Scroll wheel directly over the Volume slider
                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.NoButton
                            onWheel: (wheel) => {
                                let newVol = volWidget.volPercent + (wheel.angleDelta.y > 0 ? 5 : -5);
                                newVol = Math.max(0, Math.min(100, newVol));
                                
                                if (volWidget.audio) volWidget.audio.volume = newVol / 100.0;
                                Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", (newVol / 100.0).toFixed(2)]);
                            }
                        }

                        background: Rectangle {
                            x: volSlider.leftPadding
                            y: volSlider.topPadding + volSlider.availableHeight / 2 - height / 2
                            width: volSlider.availableWidth; height: 6
                            radius: 3; color: Colors.bg2

                            Rectangle {
                                width: volSlider.visualPosition * parent.width
                                height: parent.height
                                color: Colors.blue; radius: 3
                            }
                        }
                        handle: Rectangle {
                            x: volSlider.leftPadding + volSlider.visualPosition * (volSlider.availableWidth - width)
                            y: volSlider.topPadding + volSlider.availableHeight / 2 - height / 2
                            width: 16; height: 16; radius: 8
                            color: Colors.bg0; border.color: Colors.blue; border.width: 4
                        }
                    }
                }

                // ==========================
                // 2. BRIGHTNESS SECTION
                // ==========================
                Item {
                    width: parent.width; height: 45

                    Item {
                        width: parent.width; height: 20
                        
                        Row {
                            anchors.left: parent.left; spacing: 8
                            Rectangle {
                                width: 18; height: 18; radius: 9
                                color: "transparent"; border.color: Colors.orange; border.width: 1
                                anchors.verticalCenter: parent.verticalCenter
                                Text { anchors.centerIn: parent; text: "󰃠"; color: Colors.orange; font.pixelSize: 10; font.family: "JetBrainsMono Nerd Font" }
                            }
                            Text { text: "Brightness"; color: Colors.orange; font.pixelSize: 13; font.family: "JetBrainsMono Nerd Font"; anchors.verticalCenter: parent.verticalCenter }
                        }
                        Text { anchors.right: parent.right; text: volWidget.briPercent + "%"; color: Colors.orange; font.pixelSize: 13; font.family: "JetBrainsMono Nerd Font" }
                    }

                    Slider {
                        id: briSlider
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 24 
                        from: 0; to: 100
                        
                        focusPolicy: Qt.NoFocus 
                        
                        Binding {
                            target: briSlider
                            property: "value"
                            value: volWidget.briPercent
                            when: !briSlider.pressed
                        }
                        
                        onValueChanged: {
                            if (pressed) {
                                volWidget.briPercent = Math.round(value); 
                                Quickshell.execDetached(["brightnessctl", "set", Math.round(value) + "%"]);
                            }
                        }

                        // Scroll wheel directly over the Brightness slider
                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.NoButton 
                            onWheel: (wheel) => {
                                let newBri = volWidget.briPercent + (wheel.angleDelta.y > 0 ? 5 : -5);
                                newBri = Math.max(0, Math.min(100, newBri));
                                volWidget.briPercent = newBri; 
                                Quickshell.execDetached(["brightnessctl", "set", newBri + "%"]);
                            }
                        }

                        background: Rectangle {
                            x: briSlider.leftPadding
                            y: briSlider.topPadding + briSlider.availableHeight / 2 - height / 2
                            width: briSlider.availableWidth; height: 6
                            radius: 3; color: Colors.bg2

                            Rectangle {
                                width: briSlider.visualPosition * parent.width
                                height: parent.height
                                color: Colors.green; radius: 3 
                            }
                        }
                        handle: Rectangle {
                            x: briSlider.leftPadding + briSlider.visualPosition * (briSlider.availableWidth - width)
                            y: briSlider.topPadding + briSlider.availableHeight / 2 - height / 2
                            width: 16; height: 16; radius: 8
                            color: Colors.bg0; border.color: Colors.green; border.width: 4
                        }
                    }
                }
            }
        }
    }
}
