import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import QtQuick

Rectangle {
    id: sysPill

    visible: Config.showWifi || Config.showBattery

    width: sysContent.width + 24
    height: 32
    radius: 16
    color: Colors.bg2

    // --- 1. NATIVE BATTERY LOGIC ---
    readonly property int batLevel: UPower.displayDevice?.ready ? Math.round(UPower.displayDevice.percentage * 100) : 0
    readonly property bool isPluggedIn: !UPower.onBattery

    // --- 2. SMART NETWORK LOGIC ---
    property string netType: "none" // "wifi", "wired", or "none"
    property int wifiLevel: 0

    Timer {
        interval: 3000
        running: Config.showWifi
        repeat: true
        onTriggered: {
            // Only trigger if the process isn't already running
            if (!netProcess.running) {
                netProcess.running = true;
            }
        }
    }

    Process {
        id: netProcess
        running: Config.showWifi

        command: ["bash", "-c", "nmcli -t -f TYPE,STATE dev; echo '---'; nmcli -t -f IN-USE,SIGNAL dev wifi 2>/dev/null"]

        // THE FIX: Properly using Quickshell's IO Parser
        property string fullOutput: ""

        stdout: SplitParser {
            onRead: data => {
                netProcess.fullOutput += data + "\n";
            }
        }

        onExited: {
            let raw = fullOutput.trim();
            fullOutput = ""; // MUST reset for the next timer loop!

            if (raw === "")
                return;

            let sections = raw.split("---\n");
            if (sections.length >= 2) {
                let devState = sections[0];
                let wifiState = sections[1];

                // 1. Check for Wired Connection
                if (devState.includes("ethernet:connected")) {
                    sysPill.netType = "wired";
                    sysPill.wifiLevel = 0;
                } else
                // 2. Check for Wi-Fi Connection
                if (devState.includes("wifi:connected")) {
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
                } else
                // 3. Disconnected
                {
                    sysPill.netType = "none";
                    sysPill.wifiLevel = 0;
                }
            }
        }
    }

    Row {
        id: sysContent
        anchors.centerIn: parent
        spacing: 12

        // --- Network Icons Container ---
        Item {
            width: 18
            height: 16
            anchors.verticalCenter: parent.verticalCenter
            visible: Config.showWifi

            // Icon A: Wi-Fi Radar
            Canvas {
                id: wifiCanvas
                anchors.fill: parent
                visible: sysPill.netType === "wifi" || sysPill.netType === "none"
                antialiasing: true

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();
                    ctx.clearRect(0, 0, width, height);
                    ctx.lineWidth = 2.0;
                    ctx.lineCap = "round";

                    var cx = width / 2;
                    var cy = height - 2;

                    function drawArc(r, active) {
                        if (!active)
                            return;
                        ctx.beginPath();
                        ctx.strokeStyle = Colors.fg0;
                        ctx.arc(cx, cy, r, Math.PI * 1.25, Math.PI * 1.75);
                        ctx.stroke();
                    }

                    // Base Dot (Dimmed to Colors.fg3 if offline)
                    ctx.beginPath();
                    ctx.fillStyle = sysPill.netType === "wifi" && sysPill.wifiLevel > 0 ? Colors.fg0 : Colors.fg3;
                    ctx.arc(cx, cy, 1.5, 0, Math.PI * 2);
                    ctx.fill();

                    // Draws arcs based on nmcli's native 0-100% signal
                    if (sysPill.netType === "wifi" && sysPill.wifiLevel > 0) {
                        drawArc(5, sysPill.wifiLevel > 25);
                        drawArc(9, sysPill.wifiLevel > 50);
                        drawArc(13, sysPill.wifiLevel > 75);
                    }
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

            // Icon B: Wired Ethernet Tree
            Canvas {
                id: wiredCanvas
                anchors.fill: parent
                visible: sysPill.netType === "wired"
                antialiasing: true

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();
                    ctx.clearRect(0, 0, width, height);
                    ctx.lineWidth = 1.5;
                    ctx.strokeStyle = Colors.fg0;
                    ctx.fillStyle = Colors.fg0;

                    // Top dot
                    ctx.beginPath();
                    ctx.arc(9, 2, 1.5, 0, Math.PI * 2);
                    ctx.fill();
                    // Vertical drop
                    ctx.beginPath();
                    ctx.moveTo(9, 3);
                    ctx.lineTo(9, 7);
                    ctx.stroke();
                    // Horizontal bar
                    ctx.beginPath();
                    ctx.moveTo(4, 7);
                    ctx.lineTo(14, 7);
                    ctx.stroke();

                    // 3 Vertical branches
                    ctx.beginPath();
                    ctx.moveTo(4, 7);
                    ctx.lineTo(4, 11);
                    ctx.moveTo(9, 7);
                    ctx.lineTo(9, 11);
                    ctx.moveTo(14, 7);
                    ctx.lineTo(14, 11);
                    ctx.stroke();

                    // 3 Bottom dots
                    ctx.beginPath();
                    ctx.arc(4, 12, 1.5, 0, Math.PI * 2);
                    ctx.fill();
                    ctx.beginPath();
                    ctx.arc(9, 12, 1.5, 0, Math.PI * 2);
                    ctx.fill();
                    ctx.beginPath();
                    ctx.arc(14, 12, 1.5, 0, Math.PI * 2);
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
            spacing: 2
            visible: Config.showBattery

            Rectangle {
                width: typeof Config.batteryWidth !== "undefined" ? Config.batteryWidth : 30
                height: 14
                radius: 3
                color: "transparent"
                border.color: Colors.fg3
                border.width: 1.5

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.margins: 1.5
                    radius: 1.5
                    width: Math.max(0, (parent.width - 3) * (sysPill.batLevel / 100))

                    color: sysPill.isPluggedIn ? Colors.aqua : Colors.aqua

                    SequentialAnimation on opacity {
                        running: sysPill.isPluggedIn
                        loops: Animation.Infinite
                        NumberAnimation {
                            from: 0.6
                            to: 1.0
                            duration: 1200
                            easing.type: Easing.InOutQuad
                        }
                        NumberAnimation {
                            from: 1.0
                            to: 0.6
                            duration: 1200
                            easing.type: Easing.InOutQuad
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: (sysPill.isPluggedIn ? "⚡ " : "") + sysPill.batLevel
                    font.family: Config.fontName
                    font.pixelSize: 9
                    font.bold: true

                    color: Colors.bg0
                    style: Text.Outline
                    styleColor: sysPill.isPluggedIn ? Colors.aqua : Colors.aqua
                    z: 2
                }
            }
            Rectangle {
                width: 2
                height: 6
                radius: 1
                color: Colors.fg3
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
