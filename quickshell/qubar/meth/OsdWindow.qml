import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import ".."

PanelWindow {
    id: osdRoot

    anchors.bottom: true
    implicitWidth: 240
    implicitHeight: 130
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    visible: osdOpacity > 0

    property real osdOpacity: 0
    Behavior on osdOpacity {
        NumberAnimation {
            duration: 150
        }
    }

    property bool isReady: false
    Timer {
        interval: 1000
        running: true
        onTriggered: osdRoot.isReady = true
    }

    Timer {
        id: hideTimer
        interval: 2000
        onTriggered: osdRoot.osdOpacity = 0
    }

    property int currentMode: 0

    function showOsd(mode) {
        if (!osdRoot.isReady)
            return;
        osdRoot.currentMode = mode;
        osdRoot.osdOpacity = 1;
        hideTimer.restart();
    }

    // VOLUME TRACKING
    PwObjectTracker {
        objects: Pipewire.defaultAudioSink ? [Pipewire.defaultAudioSink] : []
    }
    property var audio: Pipewire.defaultAudioSink?.audio
    property int volPercent: audio ? Math.round(audio.volume * 100) : 0
    property bool isMuted: audio ? audio.muted : false

    onVolPercentChanged: osdRoot.showOsd(0)
    onIsMutedChanged: osdRoot.showOsd(0)

    // BRIGHTNESS TRACKING
    property int briPercent: 50
    property int maxBri: 1
    property string backlightPath: ""

    Process {
        id: initProc
        command: ["bash", "-c", "ls -1 /sys/class/backlight | head -n 1"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                let dir = data.trim();
                if (dir !== "") {
                    osdRoot.backlightPath = "/sys/class/backlight/" + dir;
                }
            }
        }
    }

    FileView {
        id: maxFile
        path: osdRoot.backlightPath !== "" ? osdRoot.backlightPath + "/max_brightness" : ""

        onLoaded: {
            let val = parseInt(maxFile.text().trim());
            if (!isNaN(val)) {
                osdRoot.maxBri = val;
                if (brightFile.loaded)
                    brightFile.reload();
            }
        }
    }

    FileView {
        id: brightFile
        path: osdRoot.backlightPath !== "" ? osdRoot.backlightPath + "/actual_brightness" : ""
        watchChanges: true
        onFileChanged: brightFile.reload()

        onLoaded: {
            let val = parseInt(brightFile.text().trim());
            if (!isNaN(val) && osdRoot.maxBri > 0) {
                let newBri = Math.round((val / osdRoot.maxBri) * 100);
                if (osdRoot.briPercent !== newBri) {
                    osdRoot.briPercent = newBri;
                    osdRoot.showOsd(1);
                }
            }
        }
    }

    // THE OSD UI
    Rectangle {
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

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: {
                    if (osdRoot.currentMode === 0)
                        return osdRoot.isMuted ? "󰝟" : (osdRoot.volPercent > 50 ? "󰕾" : (osdRoot.volPercent > 0 ? "󰖀" : "󰕿"));
                    return "󰃠";
                }
                color: {
                    if (osdRoot.currentMode === 0)
                        return osdRoot.isMuted ? Colors.red : Colors.blue;
                    return Colors.orange;
                }
                font.pixelSize: 20
                font.family: "JetBrainsMono Nerd Font"
            }

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

                    Behavior on width {
                        NumberAnimation {
                            duration: 100
                            easing.type: Easing.OutQuad
                        }
                    }
                }
            }

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
