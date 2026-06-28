import Quickshell.Services.UPower
import Quickshell.Networking
import QtQuick

Rectangle {
    id: sysPill

    visible: Config.showWifi || Config.showBattery
    width: sysContent.width + Config.sysPillPadding
    height: Config.sysPillHeight
    radius: Config.sysPillRadius
    color: hoverArea.containsMouse ? Colors.bg3 : Colors.bg2

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }

    readonly property int batLevel: (UPower.displayDevice && UPower.displayDevice.ready) ? Math.round(UPower.displayDevice.percentage * 100) : 0
    readonly property bool isPluggedIn: !UPower.onBattery

    property var wifiDevice: Networking.devices ? Networking.devices.values.find(d => d.type === DeviceType.Wifi) : null
    property var activeWifi: wifiDevice ? wifiDevice.networks.values.find(n => n.connected) : null

    property var wiredDevice: Networking.devices ? Networking.devices.values.find(d => d.type !== DeviceType.Wifi && (d.state === 100 || d.state === 2)) : null

    property string netType: wiredDevice ? "wired" : (activeWifi ? "wifi" : "none")
    property int wifiLevel: activeWifi ? Math.round(activeWifi.signalStrength * 100) : 0

    Row {
        id: sysContent
        anchors.centerIn: parent
        spacing: Config.sysPillSpacing

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

                property string _net: sysPill.netType
                property int _lvl: sysPill.wifiLevel
                on_NetChanged: requestPaint()
                on_LvlChanged: requestPaint()

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();
                    ctx.clearRect(0, 0, width, height);
                    ctx.lineWidth = Config.wifiLineWidth;
                    ctx.lineCap = "round";
                    var cx = width / 2;
                    var cy = height - 2;

                    var isConnected = (sysPill.netType === "wifi" && sysPill.wifiLevel > 0);

                    ctx.beginPath();
                    ctx.fillStyle = isConnected ? Colors.aqua : Colors.fg3;
                    ctx.arc(cx, cy, 1.5, 0, Math.PI * 2);
                    ctx.fill();

                    function drawArc(r, threshold) {
                        ctx.beginPath();
                        ctx.strokeStyle = (isConnected && sysPill.wifiLevel >= threshold) ? Colors.aqua : Colors.fg3;
                        ctx.arc(cx, cy, r, Math.PI * 1.25, Math.PI * 1.75);
                        ctx.stroke();
                    }

                    drawArc(4.5, 25);
                    drawArc(8.5, 50);
                    drawArc(12.5, 75);
                }
            }

            Canvas {
                id: wiredCanvas
                anchors.fill: parent
                visible: sysPill.netType === "wired"
                antialiasing: true

                property string _net: sysPill.netType
                on_NetChanged: requestPaint()

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();
                    ctx.clearRect(0, 0, width, height);
                    ctx.lineWidth = Math.max(1.5, Config.wifiLineWidth - 0.5);
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
            }
        }

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
