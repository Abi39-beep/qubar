import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import ".."

Item {
    id: btRoot
    width: (parent.width - 15) / 2
    height: 65

    signal closeMainPanel

    property bool isBtOn: false
    property string activeBtDevice: ""
    property bool isWiredHeadset: false

    ListModel {
        id: btModel
    }

    Process {
        id: refreshStatus
        command: ["bash", "-c", "bluetoothctl show | grep 'Powered: yes'; echo '---'; bluetoothctl devices Connected; echo '---'; bluetoothctl devices; echo '---'; pactl list sinks | grep -i 'Active Port:.*headphone'"]
        property string fullOutput: ""
        stdout: SplitParser {
            onRead: data => {
                refreshStatus.fullOutput += data + "\n";
            }
        }
        onExited: {
            let sections = fullOutput.split("---\n");
            fullOutput = "";
            if (sections.length >= 4) {
                btRoot.isBtOn = sections[0].indexOf("Powered: yes") !== -1;

                let connectedMacs = {};
                let connectedLines = sections[1].split("\n");
                btRoot.activeBtDevice = "";

                for (let i = 0; i < connectedLines.length; i++) {
                    if (connectedLines[i].startsWith("Device ")) {
                        let parts = connectedLines[i].split(" ");
                        connectedMacs[parts[1]] = true;
                        btRoot.activeBtDevice = parts.slice(2).join(" ");
                    }
                }

                btModel.clear();
                let allLines = sections[2].split("\n");
                for (let i = 0; i < allLines.length; i++) {
                    if (allLines[i].startsWith("Device ")) {
                        let parts = allLines[i].split(" ");
                        let mac = parts[1];
                        let name = parts.slice(2).join(" ");
                        btModel.append({
                            "mac": mac,
                            "name": name,
                            "connected": (connectedMacs[mac] === true)
                        });
                    }
                }
                btRoot.isWiredHeadset = sections[3].trim().length > 0;
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: refreshStatus.running = true
    }

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: Colors.bg1
        border.color: Colors.bg2
        border.width: 1

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                btRoot.closeMainPanel();
                btPopupWindow.visible = true;
                refreshStatus.running = true;
            }
        }

        Row {
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 12

            Rectangle {
                width: 40
                height: 40
                radius: 20
                color: btRoot.isWiredHeadset ? Colors.blue : (btRoot.isBtOn ? Colors.aqua : Colors.bg3)
                Text {
                    anchors.centerIn: parent
                    text: btRoot.isWiredHeadset ? "󰋋" : (btRoot.isBtOn ? "󰂯" : "󰂲")
                    color: (btRoot.isBtOn || btRoot.isWiredHeadset) ? Colors.bg0 : Colors.fg
                    font.pixelSize: 20
                    font.family: "JetBrainsMono Nerd Font"
                }
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2
                Text {
                    text: btRoot.isWiredHeadset ? "Headset" : "Bluetooth"
                    color: Colors.fg
                    font.bold: true
                    font.pixelSize: 14
                }
                Text {
                    text: {
                        if (btRoot.isWiredHeadset)
                            return "Wired Headset";
                        if (btRoot.activeBtDevice !== "")
                            return btRoot.activeBtDevice;
                        return btRoot.isBtOn ? "On" : "Off";
                    }
                    color: Colors.grey1
                    font.pixelSize: 11
                    width: 100
                    elide: Text.ElideRight
                }
            }
        }
    }

    PanelWindow {
        id: btPopupWindow
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        color: "transparent"
        visible: false
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        MouseArea {
            anchors.fill: parent
            onClicked: btPopupWindow.visible = false
        }

        Rectangle {
            anchors.centerIn: parent
            width: 340
            height: 200
            color: Qt.alpha(Colors.bg0, 0.98)
            border.color: Colors.bg2
            border.width: 1
            radius: 12

            focus: true
            Keys.onEscapePressed: btPopupWindow.visible = false
            onVisibleChanged: {
                if (visible)
                    forceActiveFocus();
            }

            MouseArea {
                anchors.fill: parent
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    Text {
                        Layout.fillWidth: true
                        text: "Bluetooth Devices"
                        color: Colors.fg
                        font.bold: true
                        font.pixelSize: 16
                    }

                    Text {
                        text: "󰑐"
                        color: Colors.blue
                        font.pixelSize: 18
                        font.family: "JetBrainsMono Nerd Font"
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: refreshStatus.running = true
                        }
                    }

                    Text {
                        text: "󰒓"
                        color: Colors.fg
                        font.pixelSize: 18
                        font.family: "JetBrainsMono Nerd Font"
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                Quickshell.execDetached(["overskride"]);
                                btPopupWindow.visible = false;
                            }
                        }
                    }

                    Rectangle {
                        width: 36
                        height: 18
                        radius: 9
                        color: btRoot.isBtOn ? Colors.aqua : Colors.bg3
                        Rectangle {
                            x: btRoot.isBtOn ? 18 : 2
                            anchors.verticalCenter: parent.verticalCenter
                            width: 14
                            height: 14
                            radius: 7
                            color: Colors.bg0
                            Behavior on x {
                                NumberAnimation {
                                    duration: 150
                                }
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                Quickshell.execDetached(["bluetoothctl", "power", btRoot.isBtOn ? "off" : "on"]);
                                btRoot.isBtOn = !btRoot.isBtOn;
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Colors.bg2
                }

                // SCROLLABLE LIST VIEW
                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true // Takes up remaining space in the 220px window
                    clip: true // ESSENTIAL: Hides items that scroll out of the 220px box
                    spacing: 6
                    model: btModel

                    // Optimization for smoother scrolling
                    boundsBehavior: Flickable.StopAtBounds

                    delegate: Rectangle {
                        width: 310
                        height: 38
                        radius: 8
                        color: model.connected ? Qt.alpha(Colors.aqua, 0.1) : "transparent"
                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            text: model.name
                            color: model.connected ? Colors.aqua : Colors.fg
                            font.pixelSize: 13
                            elide: Text.ElideRight
                            width: 180
                        }
                        Rectangle {
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            width: 85
                            height: 26
                            radius: 6
                            color: model.connected ? Colors.red : Colors.bg3
                            Text {
                                anchors.centerIn: parent
                                text: model.connected ? "Disconnect" : "Connect"
                                color: Colors.fg
                                font.pixelSize: 10
                                font.bold: true
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: Quickshell.execDetached(["bluetoothctl", model.connected ? "disconnect" : "connect", model.mac])
                            }
                        }
                    }
                }
            }
        }
    }
}
