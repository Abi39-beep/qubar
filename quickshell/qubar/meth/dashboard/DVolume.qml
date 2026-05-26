import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import "../.."

Column {
    width: parent.width
    spacing: 15

    PwObjectTracker {
        objects: Pipewire.defaultAudioSink ? [Pipewire.defaultAudioSink] : []
    }
    property var audio: Pipewire.defaultAudioSink?.audio
    property int volPercent: audio ? Math.round(audio.volume * 100) : 0

    property int briPercent: 50
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: getBri.running = true
        Component.onCompleted: getBri.running = true
    }
    Process {
        id: getBri
        command: ["brightnessctl", "-m"]
        stdout: SplitParser {
            onRead: data => {
                let parts = data.split(",");
                if (parts.length >= 4)
                    briPercent = parseInt(parts[3].replace("%", ""));
            }
        }
    }

    Item {
        width: parent.width
        height: 45
        Item {
            width: parent.width
            height: 20
            Row {
                anchors.left: parent.left
                spacing: 8
                Text {
                    text: (volPercent === 0) ? "󰝟" : (volPercent < 66 ? "󰖀" : "󰕾")
                    color: Colors.blue
                    font.pixelSize: 14
                    font.family: "JetBrainsMono Nerd Font"
                }
                Text {
                    text: "Volume"
                    color: Colors.blue
                    font.pixelSize: 13
                }
            }
            Text {
                anchors.right: parent.right
                text: volPercent + "%"
                color: Colors.blue
                font.pixelSize: 13
            }
        }
        Slider {
            id: volSlider
            anchors.bottom: parent.bottom
            width: parent.width
            height: 24
            from: 0
            to: 100
            value: volPercent
            focusPolicy: Qt.NoFocus
            onMoved: {
                if (audio)
                    audio.volume = value / 100.0;
            }
            onPressedChanged: {
                if (!pressed)
                    Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", (value / 100.0).toFixed(2)]);
            }
            background: Rectangle {
                height: 6
                radius: 3
                color: Colors.bg2
                Rectangle {
                    width: volSlider.visualPosition * parent.width
                    height: parent.height
                    color: Colors.blue
                    radius: 3
                }
            }
            handle: Rectangle {
                x: volSlider.visualPosition * (volSlider.availableWidth - width)
                width: 16
                height: 16
                radius: 8
                color: Colors.bg0
                border.color: Colors.blue
                border.width: volSlider.pressed ? 6 : 4
            }
        }
    }

    Item {
        width: parent.width
        height: 45
        Item {
            width: parent.width
            height: 20
            Row {
                anchors.left: parent.left
                spacing: 8
                Text {
                    text: briPercent < 66 ? "󰃟" : "󰃠"
                    color: Colors.orange
                    font.pixelSize: 14
                    font.family: "JetBrainsMono Nerd Font"
                }
                Text {
                    text: "Brightness"
                    color: Colors.orange
                    font.pixelSize: 13
                }
            }
            Text {
                anchors.right: parent.right
                text: briPercent + "%"
                color: Colors.orange
                font.pixelSize: 13
            }
        }
        Slider {
            id: briSlider
            anchors.bottom: parent.bottom
            width: parent.width
            height: 24
            from: 0
            to: 100
            value: briPercent
            focusPolicy: Qt.NoFocus
            onMoved: {
                briPercent = Math.round(value);
            }
            onPressedChanged: {
                if (!pressed)
                    Quickshell.execDetached(["brightnessctl", "set", Math.round(value) + "%"]);
            }
            background: Rectangle {
                height: 6
                radius: 3
                color: Colors.bg2
                Rectangle {
                    width: briSlider.visualPosition * parent.width
                    height: parent.height
                    color: Colors.orange
                    radius: 3
                }
            }
            handle: Rectangle {
                x: briSlider.visualPosition * (briSlider.availableWidth - width)
                width: 16
                height: 16
                radius: 8
                color: Colors.bg0
                border.color: Colors.orange
                border.width: briSlider.pressed ? 6 : 4
            }
        }
    }
}
