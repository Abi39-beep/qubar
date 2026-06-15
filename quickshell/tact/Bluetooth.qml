import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: root
    signal openMenuRequested

    property bool isRadioOn: false
    property string currentDevice: ""

    height: Config.ccToggleHeight
    radius: Config.ccToggleRadius

    color: isRadioOn ? Colors.aqua : Colors.bg0
    border.color: Colors.bg3
    border.width: isRadioOn ? 0 : 1

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

    // THE FIX: Forces an output even if it's empty, completely fixing the "Stuck Name" bug!
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
            color: root.isRadioOn ? Qt.rgba(0, 0, 0, 0.15) : Colors.bg1

            Text {
                anchors.centerIn: parent
                text: root.getBtIcon()
                font.family: Config.fontName
                font.pixelSize: Config.fontSizeCcToggleIcon
                color: root.isRadioOn ? Colors.bg0 : Colors.fg0

                opacity: !root.isRadioOn ? 0.2 : (root.currentDevice !== "" ? 1.0 : 0.6)
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
                    let cmd = root.isRadioOn ? "bluetoothctl power off" : "bluetoothctl power on";
                    Qt.createQmlObject('import Quickshell.Io; Process { command: ["bash", "-c", "' + cmd + '"]; running: true }', root, "toggleProc");
                    root.isRadioOn = !root.isRadioOn;

                    // Instantly clears the name if power is turned off!
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
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.openMenuRequested()
            }
        }
    }
}
