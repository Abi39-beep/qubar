import Quickshell
import Quickshell.Io
import QtQuick

Rectangle {
    id: sysPill
    anchors.verticalCenter: parent.verticalCenter
    width: sysContent.width + 24
    height: 32
    radius: 16
    color: Colors.bg2

    property int batLevel: 100
    property string batStatus: "Discharging"
    property int wifiLevel: 0

    Process {
        id: sysInfoChecker
        command: ["bash", "$HOME/.config/quickshell/tact/sys_info.sh"]
        running: true

        onStdoutChanged: {
            let rawString = stdout.trim();
            if (rawString === "")
                return;
            let lines = rawString.split('\n');
            let lastLine = lines[lines.length - 1].trim();
            let parts = lastLine.split('|');
            if (parts.length === 3) {
                sysPill.batLevel = parseInt(parts[0]);
                sysPill.batStatus = parts[1];
                sysPill.wifiLevel = parseInt(parts[2]);
            }
        }
    }

    Row {
        id: sysContent
        anchors.centerIn: parent
        spacing: 12

        // 1. Wi-Fi Arc (Radar) Icon using Canvas drawing
        Canvas {
            id: wifiCanvas
            width: 20
            height: 18
            anchors.verticalCenter: parent.verticalCenter
            antialiasing: true

            // Triggers a redraw if the wifi level changes
            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                ctx.lineWidth = 2.5;
                ctx.lineCap = "round";

                var cx = width / 2;
                var cy = height - 2; // Bottom origin point

                // Helper to draw arcs based on level
                function drawArc(r, active) {
                    ctx.beginPath();
                    ctx.strokeStyle = active ? Colors.fg0 : Colors.bg3;
                    // Angles to draw a top-facing pie slice
                    ctx.arc(cx, cy, r, Math.PI * 1.25, Math.PI * 1.75);
                    ctx.stroke();
                }

                // Center Dot
                ctx.beginPath();
                ctx.fillStyle = sysPill.wifiLevel > 5 ? Colors.fg0 : Colors.bg3;
                ctx.arc(cx, cy, 1.5, 0, Math.PI * 2);
                ctx.fill();

                // Draw the 3 arcs
                drawArc(5, sysPill.wifiLevel > 30);
                drawArc(9, sysPill.wifiLevel > 60);
                drawArc(13, sysPill.wifiLevel > 90);
            }

            // Force repaint when variables change
            Connections {
                target: sysPill
                function onWifiLevelChanged() {
                    wifiCanvas.requestPaint();
                }
            }
        }

        // 2. Battery Icon with Text
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            // Battery Shell (Widened to fit text)
            Rectangle {
                width: 34
                height: 18
                radius: 4
                color: "transparent"
                border.color: Colors.fg3
                border.width: 1.5

                // Battery Fill
                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.margins: 2
                    radius: 2
                    width: Math.max(0, (parent.width - 4) * (sysPill.batLevel / 100))
                    color: sysPill.batStatus === "Charging" ? Colors.aqua : (sysPill.batLevel <= 20 ? "#ff5c5c" : Colors.fg0)

                    SequentialAnimation on opacity {
                        running: sysPill.batStatus === "Charging"
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

                // Battery Text (Percentage + Lightning)
                Text {
                    anchors.centerIn: parent
                    // Adds the lightning bolt only if charging
                    text: (sysPill.batStatus === "Charging" ? "⚡ " : "") + sysPill.batLevel
                    font.family: Config.fontName
                    font.pixelSize: 10
                    font.bold: true

                    // Smart Contrast: Dark text with a light outline so it's ALWAYS readable
                    color: Colors.bg0
                    style: Text.Outline
                    styleColor: Colors.fg0
                    z: 2 // Keeps text above the fill
                }
            }

            // Battery Tip
            Rectangle {
                width: 2
                height: 8
                radius: 1
                color: Colors.fg3
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
