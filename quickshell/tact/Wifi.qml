import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: root
    signal openMenuRequested

    property bool isRadioOn: false
    property string currentSsid: ""
    property int currentSignal: 0

    property bool isHovered: menuArea.containsMouse || circleArea.containsMouse

    height: Config.ccToggleHeight
    radius: Config.ccToggleRadius

    color: isRadioOn ? (isHovered ? Qt.rgba(Colors.aqua.r, Colors.aqua.g, Colors.aqua.b, 0.85) : Colors.aqua) : (isHovered ? Colors.bg1 : Colors.bg0)

    border.color: Colors.bg3
    border.width: isRadioOn ? 0 : 1

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }

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
        command: ["bash", "-c", "val=$(nmcli -t -f ACTIVE,SIGNAL,SSID dev wifi list | grep -E '^yes|^\\*' | head -n 1); echo \"${val:-NONE}\""]
        running: true
        stdout: SplitParser {
            onRead: data => {
                let res = data.trim();
                if (res === "NONE" || res === "") {
                    root.currentSsid = "";
                    root.currentSignal = 0;
                } else {
                    let firstColon = res.indexOf(":");
                    let secondColon = res.indexOf(":", firstColon + 1);
                    if (firstColon > -1 && secondColon > -1) {
                        root.currentSignal = parseInt(res.substring(firstColon + 1, secondColon)) || 0;
                        root.currentSsid = res.substring(secondColon + 1);
                    }
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

    function getWifiOpacity(sig) {
        if (root.currentSsid === "")
            return 1.0;
        if (sig > 75)
            return 1.0;
        if (sig > 50)
            return 0.75;
        if (sig > 25)
            return 0.50;
        return 0.35;
    }

    Row {
        anchors.fill: parent
        anchors.margins: 6
        spacing: 12

        Rectangle {
            width: parent.height
            height: parent.height
            radius: width / 2

            // THE FIX: Cranked up the black overlay from 0.15 to 0.30 so it clearly pops against the aqua!
            color: root.isRadioOn ? (circleArea.containsMouse ? Qt.rgba(0, 0, 0, 0.45) : Qt.rgba(0, 0, 0, 0.30)) : (circleArea.containsMouse ? Colors.bg3 : Colors.bg2)

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }

            Text {
                anchors.centerIn: parent
                text: ""
                font.family: Config.fontName
                font.pixelSize: Config.fontSizeCcToggleIcon

                color: root.isRadioOn ? Colors.bg0 : Colors.fg0
                opacity: root.isRadioOn ? root.getWifiOpacity(root.currentSignal) : 0.6
                Behavior on opacity {
                    NumberAnimation {
                        duration: 300
                    }
                }
            }

            MouseArea {
                id: circleArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: {
                    let cmd = root.isRadioOn ? "nmcli radio wifi off" : "nmcli radio wifi on";
                    Qt.createQmlObject('import Quickshell.Io; Process { command: ["bash", "-c", "' + cmd + '"]; running: true }', root, "toggleProc");
                    root.isRadioOn = !root.isRadioOn;
                    if (!root.isRadioOn) {
                        root.currentSsid = "";
                        root.currentSignal = 0;
                    }
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
                id: menuArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: root.openMenuRequested()
            }
        }
    }
}
