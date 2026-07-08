import QtQuick
import QtQuick.Controls
import Quickshell.Io
import Quickshell.Services.UPower
import ".."

Item {
    id: profileMenuRoot
    height: mainCol.implicitHeight
    signal closeMenu

    property bool backendLimitAvailable: true
    property int batteryLimit: 80

    Process {
        id: readLimitProc
        command: ["cat", "/sys/class/power_supply/BAT0/charge_control_end_threshold"]
        running: profileMenuRoot.visible
        stdout: StdioCollector {
            onStreamFinished: {
                let val = parseInt(this.text.trim());
                if (!isNaN(val)) {
                    profileMenuRoot.batteryLimit = val;
                }
            }
        }
    }

    // 2. WRITE TO HARDWARE
    Process {
        id: writeLimitProc
    }

    Column {
        id: mainCol
        width: parent.width
        spacing: 16

        // 1. THE HEADER
        Item {
            width: parent.width
            height: 36

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                Rectangle {
                    width: 36
                    height: 36
                    radius: 18
                    color: backArea.containsMouse ? Colors.bg2 : Colors.bg1
                    border.color: Colors.bg3
                    border.width: 1
                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "←"
                        font.family: "SF Pro Display"
                        font.pixelSize: 18
                        color: Colors.fg0
                    }
                    MouseArea {
                        id: backArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: profileMenuRoot.closeMenu()
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Power & Battery"
                    font.family: "SF Pro Display"
                    font.pixelSize: 16
                    font.bold: true
                    color: Colors.fg0
                }
            }
        }

        // 2. ACTIVE PROFILE DISPLAY
        Rectangle {
            width: parent.width
            height: 64
            radius: 12
            color: Colors.bg1
            border.color: Colors.bg2
            border.width: 1

            Row {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: {
                        if (PowerProfiles.profile === PowerProfile.PowerSaver)
                            return "󰌪";
                        if (PowerProfiles.profile === PowerProfile.Performance)
                            return "󰓅";
                        return "󰾆";
                    }
                    font.family: "SF Pro Display"
                    font.pixelSize: 24
                    color: Colors.aqua
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    Text {
                        text: "Current Profile"
                        font.family: "SF Pro Display"
                        font.pixelSize: 12
                        color: Colors.fg3
                    }
                    Text {
                        text: {
                            if (PowerProfiles.profile === PowerProfile.PowerSaver)
                                return "Power Saver";
                            if (PowerProfiles.profile === PowerProfile.Performance)
                                return "Performance";
                            return "Balanced";
                        }
                        font.family: "SF Pro Display"
                        font.pixelSize: 15
                        font.bold: true
                        color: Colors.fg0
                    }
                }
            }
        }

        // 3. BATTERY HEALTH / LIMIT SLIDER
        Item {
            width: parent.width
            height: sliderCol.implicitHeight

            Column {
                id: sliderCol
                width: parent.width
                spacing: 12

                Item {
                    width: parent.width
                    height: 20

                    Text {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Battery Charge Limit"
                        font.family: "SF Pro Display"
                        font.pixelSize: 14
                        font.bold: true
                        color: Colors.fg0
                        opacity: profileMenuRoot.backendLimitAvailable ? 1.0 : 0.4
                    }

                    Text {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: profileMenuRoot.backendLimitAvailable ? (limitSlider.value + "%") : "Unsupported"
                        font.family: "SF Pro Display"
                        font.pixelSize: 14
                        color: Colors.aqua
                        font.bold: true
                        opacity: profileMenuRoot.backendLimitAvailable ? 1.0 : 0.4
                    }
                }

                Text {
                    text: "Cap the maximum charge level to prolong battery lifespan."
                    font.family: "SF Pro Display"
                    font.pixelSize: 12
                    color: Colors.fg3
                    width: parent.width
                    wrapMode: Text.WordWrap
                }

                Slider {
                    id: limitSlider
                    width: parent.width
                    from: 50
                    to: 100
                    stepSize: 5
                    value: profileMenuRoot.batteryLimit
                    enabled: profileMenuRoot.backendLimitAvailable

                    onPressedChanged: {
                        if (!pressed && enabled) {
                            let stopThreshold = value;
                            let startThreshold = Math.max(40, stopThreshold - 5);

                            writeLimitProc.command = ["sh", "-c", `sudo smbios-battery-ctl --set-custom-charge-interval=${startThreshold} ${stopThreshold}`];
                            writeLimitProc.running = true;
                        }
                    }

                    background: Rectangle {
                        x: limitSlider.leftPadding
                        y: limitSlider.topPadding + limitSlider.availableHeight / 2 - height / 2
                        implicitWidth: 200
                        implicitHeight: 8
                        width: limitSlider.availableWidth
                        height: implicitHeight
                        radius: 4
                        color: Colors.bg2
                        opacity: limitSlider.enabled ? 1.0 : 0.4

                        Rectangle {
                            width: limitSlider.visualPosition * parent.width
                            height: parent.height
                            color: Colors.aqua
                            radius: 4
                        }
                    }

                    handle: Rectangle {
                        x: limitSlider.leftPadding + limitSlider.visualPosition * (limitSlider.availableWidth - width)
                        y: limitSlider.topPadding + limitSlider.availableHeight / 2 - height / 2
                        implicitWidth: 20
                        implicitHeight: 20
                        radius: 10
                        color: limitSlider.pressed ? Colors.bg2 : Colors.bg0
                        border.color: Colors.aqua
                        border.width: 2
                        opacity: limitSlider.enabled ? 1.0 : 0.4

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }
                    }
                }
            }
        }
    }
}
