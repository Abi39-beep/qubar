import QtQuick
import Quickshell.Io
import Quickshell.Services.Pipewire
import ".."

Column {
    id: root
    width: parent.width
    spacing: 16

    property int brightnessVal: 50
    property int volumeVal: 50
    property bool volumeMuted: false
    property bool isReady: false

    onVisibleChanged: {
        if (visible) {
            isReady = false;
            readyTimer.restart();
            brightProc.running = false;
            brightProc.running = true;
        } else {
            isReady = false;
            readyTimer.stop();
        }
    }

    Timer {
        id: readyTimer
        interval: 300
        onTriggered: root.isReady = true
    }

    Process {
        id: brightProc
        command: ["sh", "-c", "brightnessctl -m | cut -d, -f4 | tr -d %"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (!brightMouseArea.pressed) {
                    let val = parseInt(this.text.trim(), 10);
                    if (!isNaN(val))
                        root.brightnessVal = val;
                }
            }
        }
    }

    Timer {
        interval: 200
        running: root.visible
        repeat: true
        onTriggered: brightProc.running = true
    }

    Process {
        id: setBrightProc
        running: false
    }

    function setBrightness(val) {
        root.brightnessVal = val;
        setBrightProc.command = ["sh", "-c", "brightnessctl s " + val + "%"];
        setBrightProc.running = true;
    }

    PwObjectTracker {
        objects: Pipewire.defaultAudioSink ? [Pipewire.defaultAudioSink] : []
    }

    property var activeAudioNode: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio : null
    property real trackedVolume: activeAudioNode ? activeAudioNode.volume : 0
    property bool trackedMute: activeAudioNode ? activeAudioNode.muted : false

    onTrackedVolumeChanged: {
        if (!volMouseArea.pressed) {
            root.volumeVal = Math.round(trackedVolume * 100);
        }
    }

    onTrackedMuteChanged: {
        root.volumeMuted = trackedMute;
    }

    function setVolume(val) {
        root.volumeVal = val;
        if (activeAudioNode) {
            activeAudioNode.volume = val / 100.0;
            if (activeAudioNode.muted && val > 0) {
                activeAudioNode.muted = false;
            }
        }
    }

    function getVolIcon(vol, muted) {
        if (muted || vol === 0)
            return "󰝟";
        if (vol > 50)
            return "󰕾";
        if (vol > 25)
            return "󰖀";
        return "󰕿";
    }

    // 1. BRIGHTNESS SLIDER
    Rectangle {
        id: briSlider
        width: parent.width
        height: 40
        radius: height / 2
        color: Colors.bg2
        border.color: Colors.bg0
        border.width: 1

        property real fillWidth: parent.width * (root.brightnessVal / 100)

        Rectangle {
            width: Math.max(parent.height, parent.fillWidth)
            height: parent.height
            radius: height / 2
            color: root.brightnessVal === 0 ? Colors.bg2 : Colors.aqua

            Behavior on width {
                NumberAnimation {
                    duration: root.isReady ? 150 : 0
                    easing.type: Easing.OutQuad
                }
            }
            Behavior on color {
                ColorAnimation {
                    duration: root.isReady ? 150 : 0
                }
            }
        }

        Item {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: parent.height
            height: parent.height

            Text {
                anchors.centerIn: parent
                text: "󰖨"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 14 + (root.brightnessVal / 100 * 6)
                color: briSlider.fillWidth > 40 ? Colors.bg0 : Colors.fg0
                rotation: root.brightnessVal * 1.8

                Behavior on font.pixelSize {
                    NumberAnimation {
                        duration: root.isReady ? 150 : 0
                    }
                }
                Behavior on rotation {
                    NumberAnimation {
                        duration: root.isReady ? 150 : 0
                    }
                }
                Behavior on color {
                    ColorAnimation {
                        duration: root.isReady ? 150 : 0
                    }
                }
            }
        }

        MouseArea {
            id: brightMouseArea
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor

            onPositionChanged: mouse => {
                if (pressed)
                    updateVal(mouse.x);
            }
            onPressed: mouse => {
                updateVal(mouse.x);
            }
            onWheel: wheel => {
                let step = wheel.angleDelta.y > 0 ? 5 : -5;
                root.setBrightness(Math.max(0, Math.min(100, root.brightnessVal + step)));
            }

            function updateVal(xPos) {
                let perc = Math.max(0, Math.min(1, xPos / width));
                root.setBrightness(Math.round(perc * 100));
            }
        }
    }

    // 2. VOLUME SLIDER
    Rectangle {
        id: volSlider
        width: parent.width
        height: 40
        radius: height / 2
        color: Colors.bg2
        border.color: Colors.bg0
        border.width: 1

        property real fillWidth: parent.width * (root.volumeVal / 100)

        Rectangle {
            width: Math.max(parent.height, parent.fillWidth)
            height: parent.height
            radius: height / 2
            color: root.volumeMuted || root.volumeVal === 0 ? Colors.bg2 : Colors.aqua

            Behavior on width {
                NumberAnimation {
                    duration: root.isReady ? 150 : 0
                    easing.type: Easing.OutQuad
                }
            }
            Behavior on color {
                ColorAnimation {
                    duration: root.isReady ? 150 : 0
                }
            }
        }

        Item {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: parent.height
            height: parent.height

            Text {
                anchors.centerIn: parent
                text: root.getVolIcon(root.volumeVal, root.volumeMuted)
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 22
                color: volSlider.fillWidth > 40 ? Colors.bg0 : Colors.fg0

                Behavior on color {
                    ColorAnimation {
                        duration: root.isReady ? 150 : 0
                    }
                }
            }
        }

        MouseArea {
            id: volMouseArea
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor

            onPositionChanged: mouse => {
                if (pressed)
                    updateVal(mouse.x);
            }
            onPressed: mouse => {
                updateVal(mouse.x);
            }
            onWheel: wheel => {
                let step = wheel.angleDelta.y > 0 ? 5 : -5;
                root.setVolume(Math.max(0, Math.min(100, root.volumeVal + step)));
            }

            function updateVal(xPos) {
                let perc = Math.max(0, Math.min(1, xPos / width));
                root.setVolume(Math.round(perc * 100));
            }
        }
    }
}
