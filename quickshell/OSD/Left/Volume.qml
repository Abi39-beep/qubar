import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import ".."

Column {
    id: volRoot
    width: parent ? parent.width : 380
    spacing: 20 // Spacing between the Volume and Brightness rows

    PwObjectTracker {
        id: pwTracker
        objects: Pipewire.defaultAudioSink ? [Pipewire.defaultAudioSink] : []
    }

    property var audio: Pipewire.defaultAudioSink?.audio
    property int volPercent: audio ? Math.round(audio.volume * 100) : 0
    property int briPercent: 50

    Timer {
        interval: 2000
        running: !briSlider.pressed
        repeat: true
        onTriggered: getBri.running = true
    }

    Process {
        id: getBri
        command: ["brightnessctl", "-m"]
        stdout: SplitParser {
            onRead: data => {
                let parts = data.split(",");
                if (parts.length >= 4 && !briSlider.pressed) {
                    volRoot.briPercent = parseInt(parts[3].replace("%", ""));
                }
            }
        }
    }

    // --- VOLUME ROW (Icon | Slider | Percentage) ---
    Row {
        width: parent.width
        height: 32
        spacing: 15

        Text {
            width: 25
            text: (volRoot.volPercent === 0) ? "󰝟" : (volRoot.volPercent < 50 ? "󰖀" : "󰕾")
            color: Colors.aqua
            font.pixelSize: 24
            font.family: "JetBrainsMono Nerd Font"
            anchors.verticalCenter: parent.verticalCenter
        }

        Slider {
            id: volSlider
            // Automatically fills the space between icon and percentage
            width: parent.width - 25 - 45 - (parent.spacing * 2)
            height: parent.height
            from: 0
            to: 100

            Binding on value {
                value: volRoot.volPercent
                when: !volSlider.pressed
            }

            onMoved: {
                if (volRoot.audio)
                    volRoot.audio.volume = value / 100.0;
            }

            onPressedChanged: {
                if (!pressed)
                    Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", (value / 100.0).toFixed(2)]);
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
                onWheel: wheel => {
                    let newVol = volRoot.volPercent + (wheel.angleDelta.y > 0 ? 5 : -5);
                    newVol = Math.max(0, Math.min(100, newVol));
                    if (volRoot.audio)
                        volRoot.audio.volume = newVol / 100.0;
                    Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", (newVol / 100.0).toFixed(2)]);
                }
            }

            background: Rectangle {
                x: volSlider.leftPadding
                y: volSlider.topPadding + volSlider.availableHeight / 2 - height / 2
                width: volSlider.availableWidth
                height: 20
                radius: 9
                color: Colors.bg2
                Rectangle {
                    width: volSlider.visualPosition * parent.width
                    height: parent.height
                    color: Colors.aqua
                    radius: 9
                }
            }
            handle: Rectangle {
                x: volSlider.leftPadding + volSlider.visualPosition * (volSlider.availableWidth - width)
                y: volSlider.topPadding + volSlider.availableHeight / 2 - height / 2
                width: 0
                height: 0
                radius: 12
                color: Colors.bg2
                border.color: Colors.aqua
                border.width: volSlider.pressed ? 10 : 6
            }
        }

        Text {
            width: 45
            text: volRoot.volPercent + "%"
            color: Colors.aqua
            font.pixelSize: 15
            font.family: "JetBrainsMono Nerd Font"
            horizontalAlignment: Text.AlignRight
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // --- BRIGHTNESS ROW (Icon | Slider | Percentage) ---
    Row {
        width: parent.width
        height: 32
        spacing: 15

        Text {
            width: 25
            text: volRoot.briPercent < 50 ? "󰃟" : "󰃠"
            color: Colors.orange
            font.pixelSize: 20
            font.family: "JetBrainsMono Nerd Font"
            anchors.verticalCenter: parent.verticalCenter
        }

        Slider {
            id: briSlider
            width: parent.width - 25 - 45 - (parent.spacing * 2)
            height: parent.height
            from: 0
            to: 100

            Binding on value {
                value: volRoot.briPercent
                when: !briSlider.pressed
            }

            onMoved: {
                volRoot.briPercent = Math.round(value);
                Quickshell.execDetached(["brightnessctl", "set", Math.round(value) + "%"]);
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
                onWheel: wheel => {
                    let newBri = volRoot.briPercent + (wheel.angleDelta.y > 0 ? 5 : -5);
                    newBri = Math.max(0, Math.min(100, newBri));
                    volRoot.briPercent = newBri;
                    Quickshell.execDetached(["brightnessctl", "set", newBri + "%"]);
                }
            }

            background: Rectangle {
                x: briSlider.leftPadding
                y: briSlider.topPadding + briSlider.availableHeight / 2 - height / 2
                width: briSlider.availableWidth
                height: 20
                radius: 9
                color: Colors.bg2
                Rectangle {
                    width: briSlider.visualPosition * parent.width
                    height: parent.height
                    color: Colors.orange
                    radius: 9
                }
            }
            handle: Rectangle {
                x: briSlider.leftPadding + briSlider.visualPosition * (briSlider.availableWidth - width)
                y: briSlider.topPadding + briSlider.availableHeight / 2 - height / 2
                width: 0
                height: 0
                radius: 12
                color: Colors.bg2
                border.color: Colors.orange
                border.width: briSlider.pressed ? 10 : 6
            }
        }

        Text {
            width: 45
            text: volRoot.briPercent + "%"
            color: Colors.orange
            font.pixelSize: 15
            font.family: "JetBrainsMono Nerd Font"
            horizontalAlignment: Text.AlignRight
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
