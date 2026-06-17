import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import QtQuick

Rectangle {
    id: sysPill

    visible: Config.showWifi || Config.showBattery

    width: sysContent.width + Config.sysPillPadding
    height: Config.sysPillHeight
    radius: Config.sysPillRadius

    // THE FIX: Smoothly shifts to bg3 when hovered!
    color: hoverArea.containsMouse ? Colors.bg3 : Colors.bg2
    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }

    // THE MAGIC HOVER DETECTOR
    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton // Ignores clicks so PillBar can still open the Control Center!
    }

    // --- 1. NATIVE BATTERY LOGIC ---
    readonly property int batLevel: UPower.displayDevice?.ready ? Math.round(UPower.displayDevice.percentage * 100) : 0
    readonly property bool isPluggedIn: !UPower.onBattery

    // --- 2. SMART NETWORK LOGIC ---
    property string netType: "none"
    property int wifiLevel: 0

    Timer {
        interval: 3000
        running: Config.showWifi
        repeat: true
        onTriggered: {
            if (!netProcess.running) {
                netProcess.running = true;
            }
        }
    }

    Process {
        id: netProcess
        running: Config.showWifi

        command: ["bash", "-c", "nmcli -t -f TYPE,STATE dev; echo '---'; nmcli -t -f IN-USE,SIGNAL dev wifi 2>/dev/null"]

        property string fullOutput: ""

        stdout: SplitParser {
            onRead: data => {
                netProcess.fullOutput += data + "\n";
            }
        }

        onExited: {
            let raw = fullOutput.trim();
            fullOutput = "";

            if (raw === "")
                return;

            let sections = raw.split("---\n");
            if (sections.length >= 2) {
                let devState = sections[0];
                let wifiState = sections[1];

                if (devState.includes("ethernet:connected")) {
                    sysPill.netType = "wired";
                    sysPill.wifiLevel = 0;
                } else if (devState.includes("wifi:connected")) {
                    sysPill.netType = "wifi";
                    let lines = wifiState.split("\n");
                    let sig = 0;
                    for (let i = 0; i < lines.length; i++) {
                        if (lines[i].startsWith("*")) {
                            let parts = lines[i].split(":");
                            if (parts.length >= 2) {
                                sig = parseInt(parts[1]);
                            }
                            break;
                        }
                    }
                    sysPill.wifiLevel = isNaN(sig) ? 0 : sig;
                } else {
                    sysPill.netType = "none";
                    sysPill.wifiLevel = 0;
                }
            }
        }
    }

    Row {
        id: sysContent
        anchors.centerIn: parent
        spacing: Config.sysPillSpacing

        // --- Network Icons Container ---
        Item {
            width: Config.wifiIconWidth
            height: Config.wifiIconHeight
            anchors.verticalCenter: parent.verticalCenter
            visible: Config.showWifi

            Canvas {
                id: wifiCanvas
                anchors.fill: parent
                visible: sysPill.netType === "wifi" || sysPill.netType === "none"
                antialiasing: true

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();
                    ctx.clearRect(0, 0, width, height);

                    ctx.lineWidth = Config.wifiLineWidth;
                    ctx.lineCap = "round";

                    var cx = width / 2;
                    var cy = height - 2;

                    var activeColor = Colors.aqua;
                    var inactiveColor = Colors.fg3;

                    function drawArc(r, active) {
                        ctx.beginPath();
                        ctx.strokeStyle = active ? activeColor : inactiveColor;
                        ctx.arc(cx, cy, r, Math.PI * 1.25, Math.PI * 1.75);
                        ctx.stroke();
                    }

                    var isConnected = (sysPill.netType === "wifi" && sysPill.wifiLevel > 0);

                    ctx.beginPath();
                    ctx.fillStyle = isConnected ? activeColor : inactiveColor;
                    ctx.arc(cx, cy, 1.5, 0, Math.PI * 2);
                    ctx.fill();

                    drawArc(4.5, isConnected && sysPill.wifiLevel > 25);
                    drawArc(8.5, isConnected && sysPill.wifiLevel > 50);
                    drawArc(12.5, isConnected && sysPill.wifiLevel > 75);
                }

                Connections {
                    target: sysPill
                    function onWifiLevelChanged() {
                        wifiCanvas.requestPaint();
                    }
                    function onNetTypeChanged() {
                        wifiCanvas.requestPaint();
                    }
                }
            }

            Canvas {
                id: wiredCanvas
                anchors.fill: parent
                visible: sysPill.netType === "wired"
                antialiasing: true

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();
                    ctx.clearRect(0, 0, width, height);
                    ctx.lineWidth = Config.wifiLineWidth - 0.5;
                    ctx.strokeStyle = Colors.aqua;
                    ctx.fillStyle = Colors.aqua;

                    ctx.beginPath();
                    ctx.arc(11, 2, 1.5, 0, Math.PI * 2);
                    ctx.fill();
                    ctx.beginPath();
                    ctx.moveTo(11, 3);
                    ctx.lineTo(11, 7);
                    ctx.stroke();
                    ctx.beginPath();
                    ctx.moveTo(6, 7);
                    ctx.lineTo(16, 7);
                    ctx.stroke();

                    ctx.beginPath();
                    ctx.moveTo(6, 7);
                    ctx.lineTo(6, 11);
                    ctx.moveTo(11, 7);
                    ctx.lineTo(11, 11);
                    ctx.moveTo(16, 7);
                    ctx.lineTo(16, 11);
                    ctx.stroke();

                    ctx.beginPath();
                    ctx.arc(6, 12, 1.5, 0, Math.PI * 2);
                    ctx.fill();
                    ctx.beginPath();
                    ctx.arc(11, 12, 1.5, 0, Math.PI * 2);
                    ctx.fill();
                    ctx.beginPath();
                    ctx.arc(16, 12, 1.5, 0, Math.PI * 2);
                    ctx.fill();
                }

                Connections {
                    target: sysPill
                    function onNetTypeChanged() {
                        wiredCanvas.requestPaint();
                    }
                }
            }
        }

        // --- Battery Icon ---
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: Config.batteryTipSpacing
            visible: Config.showBattery

            Rectangle {
                width: Config.batteryWidth
                height: Config.batteryHeight
                radius: Config.batteryRadius
                color: "transparent"
                border.color: Colors.fg3
                border.width: Config.batteryBorderWidth

                // Dynamic mathematically-perfect fill calculation
                Rectangle {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: Config.batteryBorderWidth + Config.batteryFillGap

                    height: parent.height - ((Config.batteryBorderWidth + Config.batteryFillGap) * 2)
                    radius: Config.batteryFillRadius

                    width: Math.max(0, (parent.width - ((Config.batteryBorderWidth + Config.batteryFillGap) * 2)) * (sysPill.batLevel / 100))
                    color: Colors.aqua

                    SequentialAnimation on opacity {
                        running: sysPill.isPluggedIn
                        loops: Animation.Infinite
                        NumberAnimation {
                            from: 0.5
                            to: 1.0
                            duration: 1000
                            easing.type: Easing.InOutQuad
                        }
                        NumberAnimation {
                            from: 1.0
                            to: 0.5
                            duration: 1000
                            easing.type: Easing.InOutQuad
                        }
                    }
                }

                Row {
                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset: Config.batteryTextOffsetX
                    anchors.verticalCenterOffset: Config.batteryTextOffsetY
                    spacing: 1

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: sysPill.isPluggedIn
                        text: "󱐋"
                        font.family: Config.fontName
                        font.pixelSize: Config.fontSizeBattery
                        font.bold: true
                        renderType: Text.NativeRendering
                        color: sysPill.batLevel > 40 ? Colors.bg0 : Colors.fg0
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: sysPill.batLevel
                        font.family: Config.fontName
                        font.pixelSize: Config.fontSizeBattery
                        font.bold: true
                        renderType: Text.NativeRendering
                        color: sysPill.batLevel > 40 ? Colors.bg0 : Colors.fg0
                    }
                }
            }

            Rectangle {
                width: Config.batteryTipWidth
                height: Config.batteryTipHeight
                radius: Config.batteryTipRadius
                color: Colors.fg3
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
