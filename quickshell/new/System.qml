import QtQuick
import QtQuick.Layouts
import Quickshell.Io

ColumnLayout {
    id: sysRoot
    spacing: 12

    property int cpuPercent: 0
    property int memPercent: 0
    property string memLabel: "0.0 / 0.0 GB"
    property int cpuTemp: 0
    property real wavePhase: 0

    // Animates the sine wave continuously
    NumberAnimation on wavePhase {
        from: 0
        to: Math.PI * 2
        duration: 3000
        loops: Animation.Infinite
        running: true
    }

    Timer {
        interval: 2500
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            cpuFetch.running = false;
            memFetch.running = false;
            tempFetch.running = false;
            cpuFetch.running = true;
            memFetch.running = true;
            tempFetch.running = true;
        }
    }

    Process {
        id: cpuFetch
        command: ["sh", "-c", "top -bn2 -d 0.2 | grep 'Cpu(s)' | tail -n1 | awk '{print $2 + $4}' | cut -d. -f1"]
        stdout: StdioCollector {
            onStreamFinished: {
                let val = parseInt(this.text.trim(), 10);
                if (!isNaN(val))
                    sysRoot.cpuPercent = val;
            }
        }
    }

    Process {
        id: memFetch
        command: ["sh", "-c", "free -m | awk 'NR==2{printf \"%d|%.1f / %.1f GB\", $3*100/$2, $3/1024, $2/1024}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                let parts = this.text.trim().split("|");
                if (parts.length === 2) {
                    sysRoot.memPercent = parseInt(parts[0], 10);
                    sysRoot.memLabel = parts[1];
                }
            }
        }
    }

    Process {
        id: tempFetch
        command: ["sh", "-c", "cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | awk '{print $1/1000}' | sort -nr | head -n1 | awk '{print int($1)}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                let val = parseInt(this.text.trim(), 10);
                if (!isNaN(val))
                    sysRoot.cpuTemp = val;
            }
        }
    }

    // =====================================
    // 1. CPU WIDGET (CIRCULAR ARC)
    // =====================================
    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: Colors.bg1
        radius: 16
        border.color: Colors.bg2
        border.width: 2

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 6

            // HEADER: CPU Icon and Text
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: ""
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 16
                    color: Colors.aqua
                }
                Text {
                    text: "CPU"
                    font.family: "SF Pro Display"
                    font.pixelSize: 14
                    font.bold: true
                    color: Colors.fg0
                    Layout.fillWidth: true
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 12

                // LEFT SIDE: The Arc Canvas
                Item {
                    Layout.preferredWidth: 56
                    Layout.preferredHeight: 56
                    Layout.alignment: Qt.AlignVCenter

                    Canvas {
                        id: cpuCanvas
                        anchors.fill: parent
                        property real percentage: sysRoot.cpuPercent / 100.0

                        onPercentageChanged: requestPaint()

                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.clearRect(0, 0, width, height);

                            var centerX = width / 2;
                            var centerY = height / 2;
                            var radius = Math.min(width, height) / 2 - 3;

                            // Background Circle
                            ctx.beginPath();
                            ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI);
                            ctx.lineWidth = 5;
                            ctx.strokeStyle = Colors.bg2;
                            ctx.stroke();

                            // Colored Sweep Arc
                            ctx.beginPath();
                            var startAngle = 0.75 * Math.PI;
                            var endAngle = startAngle + (percentage * 1.5 * Math.PI);
                            ctx.arc(centerX, centerY, radius, startAngle, endAngle);
                            ctx.lineWidth = 5;
                            ctx.strokeStyle = Colors.aqua;
                            ctx.lineCap = "round";
                            ctx.stroke();
                        }
                    }

                    // Text inside the Arc
                    Column {
                        anchors.centerIn: parent
                        spacing: -2
                        Text {
                            text: sysRoot.cpuPercent + "%"
                            font.family: "SF Pro Display"
                            font.pixelSize: 14
                            font.bold: true
                            color: Colors.fg0
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        Text {
                            text: "Load"
                            font.family: "SF Pro Display"
                            font.pixelSize: 9
                            color: Colors.fg3
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }

                // RIGHT SIDE: Temp Bar
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignVCenter

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "Temp"
                                font.family: "SF Pro Display"
                                font.pixelSize: 12
                                color: Colors.fg2
                                Layout.fillWidth: true
                            }
                            Text {
                                text: sysRoot.cpuTemp > 0 ? sysRoot.cpuTemp + "°C" : "N/A"
                                font.family: "SF Pro Display"
                                font.pixelSize: 12
                                font.bold: true
                                color: sysRoot.cpuTemp > 80 ? "#f38ba8" : Colors.fg0
                            }
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 6
                            radius: 3
                            color: Colors.bg2
                            Rectangle {
                                width: Math.min(parent.width, parent.width * (sysRoot.cpuTemp / 100.0))
                                height: parent.height
                                radius: 3
                                color: sysRoot.cpuTemp > 80 ? "#f38ba8" : Colors.aqua
                                Behavior on width {
                                    NumberAnimation {
                                        duration: 400
                                        easing.type: Easing.OutQuart
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // =====================================
    // 2. RAM WIDGET (LIQUID WAVE + SLIDER)
    // =====================================
    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: Colors.bg1
        radius: 16
        border.color: Colors.bg2
        border.width: 2
        clip: true

        // Background Animated Wave
        Canvas {
            id: waveCanvas
            anchors.fill: parent
            anchors.margins: 2
            property real fillLevel: sysRoot.memPercent / 100.0
            property real phase: sysRoot.wavePhase

            onPhaseChanged: requestPaint()
            onFillLevelChanged: requestPaint()

            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);

                ctx.save();
                ctx.beginPath();
                ctx.roundRect(0, 0, width, height, 14);
                ctx.clip();

                var w = width;
                var h = height;
                var fillY = h - (h * fillLevel);

                // Wave Layer 1
                ctx.beginPath();
                ctx.moveTo(0, h);
                ctx.lineTo(0, fillY);
                for (var x = 0; x <= w; x += 5) {
                    var y = fillY + Math.sin(x * 0.05 + phase) * 6;
                    ctx.lineTo(x, y);
                }
                ctx.lineTo(w, h);
                ctx.closePath();
                ctx.fillStyle = Colors.green;
                ctx.globalAlpha = 0.3;
                ctx.fill();

                // Wave Layer 2
                ctx.beginPath();
                ctx.moveTo(0, h);
                ctx.lineTo(0, fillY);
                for (var x = 0; x <= w; x += 5) {
                    var y = fillY + Math.sin(x * 0.03 + phase + 2) * 8;
                    ctx.lineTo(x, y);
                }
                ctx.lineTo(w, h);
                ctx.closePath();
                ctx.fillStyle = Colors.green;
                ctx.globalAlpha = 0.6;
                ctx.fill();

                ctx.restore();
            }
        }

        // Overlay Content (Icon, GB Text, and Progress Bar)
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Text {
                    text: "󰘚"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 22
                    color: sysRoot.memPercent > 50 ? Colors.bg0 : Colors.green
                }

                Column {
                    Layout.fillWidth: true
                    Text {
                        text: "Memory"
                        font.family: "SF Pro Display"
                        font.pixelSize: 14
                        font.bold: true
                        color: sysRoot.memPercent > 50 ? Colors.bg0 : Colors.fg0
                    }
                    Text {
                        text: sysRoot.memLabel
                        font.family: "SF Pro Display"
                        font.pixelSize: 12
                        color: sysRoot.memPercent > 50 ? Colors.bg0 : Colors.fg2
                    }
                }

                Text {
                    text: sysRoot.memPercent + "%"
                    font.family: "SF Pro Display"
                    font.pixelSize: 18
                    font.bold: true
                    color: sysRoot.memPercent > 50 ? Colors.bg0 : Colors.fg0
                }
            }

            // Percentage Slide Bar for Memory
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 6
                radius: 3
                color: Colors.bg2
                opacity: sysRoot.memPercent > 50 ? 0.7 : 1.0

                Rectangle {
                    width: parent.width > 0 ? (parent.width * sysRoot.memPercent / 100) : 0
                    height: parent.height
                    radius: 3
                    color: sysRoot.memPercent > 50 ? Colors.bg0 : Colors.green

                    Behavior on width {
                        NumberAnimation {
                            duration: 500
                            easing.type: Easing.OutQuart
                        }
                    }
                }
            }
        }
    }
}
