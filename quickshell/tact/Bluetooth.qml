import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: root
    signal openMenuRequested

    property bool isRadioOn: false
    property string currentDevice: ""

    // Combines both mouse areas to detect if the mouse is ANYWHERE on the button!
    property bool isHovered: menuArea.containsMouse || circleArea.containsMouse

    height: Config.ccToggleHeight
    radius: Config.ccToggleRadius

    // Entire box shifts color on hover
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
        command: ["bash", "-c", "bluetoothctl show | grep -q 'Powered: yes' && echo 'on' || echo 'off'"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                root.isRadioOn = (data.trim() === "on");
            }
        }
    }

    Process {
        id: deviceProc
        command: ["bash", "-c", "dev=$(bluetoothctl devices Connected | head -n 1 | cut -d ' ' -f 3-); echo \"${dev:-NONE}\""]
        running: true
        stdout: SplitParser {
            onRead: data => {
                let res = data.trim();
                root.currentDevice = (res === "NONE") ? "" : res;
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            radioProc.running = true;
            deviceProc.running = true;
        }
    }

    function getBtIcon() {
        if (!isRadioOn)
            return "󰂲";
        if (currentDevice !== "")
            return "󰂱";
        return "󰂯";
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
                text: root.getBtIcon()
                font.family: Config.fontName
                font.pixelSize: Config.fontSizeCcToggleIcon

                color: root.isRadioOn ? Colors.bg0 : Colors.fg0
                opacity: root.isRadioOn ? 1.0 : 0.6
            }

            MouseArea {
                id: circleArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: {
                    let cmd = root.isRadioOn ? "bluetoothctl power off" : "bluetoothctl power on";
                    Qt.createQmlObject('import Quickshell.Io; Process { command: ["bash", "-c", "' + cmd + '"]; running: true }', root, "toggleProc");
                    root.isRadioOn = !root.isRadioOn;
                    if (!root.isRadioOn)
                        root.currentDevice = "";
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
                    text: "Bluetooth"
                    font.family: Config.fontName
                    font.pixelSize: Config.fontSizeCcToggleTitle
                    font.bold: true
                    color: root.isRadioOn ? Colors.bg0 : Colors.fg0
                }
                Text {
                    text: !root.isRadioOn ? "Off" : (root.currentDevice !== "" ? root.currentDevice : "On")
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
