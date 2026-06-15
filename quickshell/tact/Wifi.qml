import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: root
    signal openMenuRequested

    property bool isRadioOn: false
    property string currentSsid: ""
    property int currentSignal: 0

    height: Config.ccToggleHeight
    radius: Config.ccToggleRadius

    color: isRadioOn ? Colors.aqua : Colors.bg0
    border.color: Colors.bg3
    border.width: isRadioOn ? 0 : 1

    Process {
        id: radioProc
        command: ["bash", "-c", "nmcli radio wifi"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                root.isRadioOn = (data.trim() === "enabled");
            }
        }
    }

    Process {
        id: ssidProc
        command: ["bash", "-c", "nmcli -t -f ACTIVE,SIGNAL,SSID dev wifi list | grep -E '^yes|^\\*' | head -n 1"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                let line = data.trim();
                if (!line) {
                    root.currentSsid = "";
                    root.currentSignal = 0;
                    return;
                }

                let parts = line.split(":");
                if (parts.length >= 3) {
                    root.currentSignal = parseInt(parts[1]) || 0;
                    root.currentSsid = parts.slice(2).join(":");
                }
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            radioProc.running = true;
            ssidProc.running = true;
        }
    }

    // THE FIX: Fading Opacity Math for the Solid Wedge
    function getWifiOpacity(sig) {
        if (!isRadioOn || currentSsid === "")
            return 0.2; // Barely visible if off
        if (sig > 75)
            return 1.0;  // Full brightness
        if (sig > 50)
            return 0.65; // Slightly faded
        if (sig > 25)
            return 0.35; // Faded
        return 0.15;               // Weak signal
    }

    Row {
        anchors.fill: parent
        anchors.margins: 6
        spacing: 12

        Rectangle {
            width: parent.height
            height: parent.height
            radius: width / 2
            color: root.isRadioOn ? Qt.rgba(0, 0, 0, 0.15) : Colors.bg1

            // YOUR EXACT ICON: The Solid Wedge
            Text {
                anchors.centerIn: parent
                text: ""
                font.family: Config.fontName
                font.pixelSize: Config.fontSizeCcToggleIcon
                color: root.isRadioOn ? Colors.bg0 : Colors.fg0

                // Applies the dynamic signal fading!
                opacity: root.getWifiOpacity(root.currentSignal)
                Behavior on opacity {
                    NumberAnimation {
                        duration: 300
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    let cmd = root.isRadioOn ? "nmcli radio wifi off" : "nmcli radio wifi on";
                    Qt.createQmlObject('import Quickshell.Io; Process { command: ["bash", "-c", "' + cmd + '"]; running: true }', root, "toggleProc");
                    root.isRadioOn = !root.isRadioOn;
                }
            }
        }

        Item {
            width: parent.width - parent.height - 18
            height: parent.height

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Text {
                    text: "Wi-Fi"
                    font.family: Config.fontName
                    font.pixelSize: Config.fontSizeCcToggleTitle
                    font.bold: true
                    color: root.isRadioOn ? Colors.bg0 : Colors.fg0
                }
                Text {
                    text: !root.isRadioOn ? "Off" : (root.currentSsid !== "" ? root.currentSsid : "On")
                    font.family: Config.fontName
                    font.pixelSize: Config.fontSizeCcToggleSub
                    color: root.isRadioOn ? Qt.rgba(Colors.bg0.r, Colors.bg0.g, Colors.bg0.b, 0.7) : Colors.fg3
                    width: parent.width
                    elide: Text.ElideRight
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.openMenuRequested()
            }
        }
    }
}
