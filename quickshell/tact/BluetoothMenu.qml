import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: btMenuRoot
    signal backRequested

    property string expandedMac: ""
    property bool isRadioOn: false
    property bool isScanning: false
    property bool isToggling: false

    onVisibleChanged: {
        if (!visible) {
            expandedMac = "";
            if (isScanning)
                toggleScan(false);
        } else {
            fetchDevicesProc.running = false;
            fetchDevicesProc.running = true;
        }
    }

    onIsRadioOnChanged: {
        if (!isRadioOn) {
            btModel.clear();
            if (isScanning)
                toggleScan(false);
        }
    }

    Timer {
        id: toggleLockTimer
        interval: 2000
        onTriggered: btMenuRoot.isToggling = false
    }

    Process {
        id: radioProc
        command: ["bash", "-c", "bluetoothctl show | grep -q 'Powered: yes' && echo 'on' || echo 'off'"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                if (!btMenuRoot.isToggling) {
                    btMenuRoot.isRadioOn = (data.trim() === "on");
                }
            }
        }
    }
    Timer {
        id: radioTimer
        interval: 3000
        running: true
        repeat: true
        onTriggered: radioProc.running = true
    }

    // --- THE FIX: THE NATIVE DATA DRAIN ---
    Process {
        id: scanProc
        command: ["bluetoothctl", "scan", "on"]
        running: false

        // THIS IS THE MAGIC TRICK: It actively "eats" the massive text output from the scanner.
        // This stops Quickshell from freezing AND forces Linux to keep the physical radio scan alive!
        stdout: SplitParser {
            onRead: data => { /* Silently drain the text pipe */ }
        }
    }

    Timer {
        id: scanTimer
        interval: 15000
        onTriggered: toggleScan(false)
    }

    function toggleScan(start) {
        btMenuRoot.isScanning = start;
        if (start) {
            scanProc.running = false;
            scanProc.running = true;
            scanTimer.restart();
        } else {
            scanProc.running = false;
            scanTimer.stop();
            Qt.createQmlObject('import Quickshell.Io; Process { command: ["bluetoothctl", "scan", "off"]; running: true }', btMenuRoot, "stopProc");
        }
    }

    Process {
        id: actionProc
        running: false
        onExited: {
            fetchDevicesProc.running = false;
            fetchDevicesProc.running = true;
        }
    }

    Timer {
        interval: 3000
        running: btMenuRoot.visible
        repeat: true
        onTriggered: {
            fetchDevicesProc.running = false;
            fetchDevicesProc.running = true;
        }
    }

    Process {
        id: fetchDevicesProc
        command: ["bash", "-c", "connected=$(bluetoothctl devices Connected | awk '{print $2}'); bluetoothctl devices | while read -r _ mac name; do if echo \"$connected\" | grep -q \"$mac\"; then echo \"yes|$mac|$name\"; else echo \"no|$mac|$name\"; fi; done"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                let lines = data.split("\n");
                for (let i = 0; i < lines.length; i++) {
                    let line = lines[i].trim();
                    if (!line)
                        continue;

                    let parts = line.split("|");
                    if (parts.length >= 3) {
                        let isActive = (parts[0] === "yes");
                        let mac = parts[1];
                        let name = parts.slice(2).join("|").trim();

                        if (name === "")
                            name = mac;

                        let found = false;
                        for (let j = 0; j < btModel.count; j++) {
                            if (btModel.get(j).mac === mac) {
                                if (btModel.get(j).isActive !== isActive) {
                                    btModel.setProperty(j, "isActive", isActive);
                                    if (isActive)
                                        btModel.move(j, 0, 1);
                                    else
                                        btModel.move(j, btModel.count - 1, 1);
                                }

                                if (btModel.get(j).name !== name && name !== mac) {
                                    btModel.setProperty(j, "name", name);
                                }
                                found = true;
                                break;
                            }
                        }
                        if (!found) {
                            if (isActive)
                                btModel.insert(0, {
                                    "name": name,
                                    "mac": mac,
                                    "isActive": isActive
                                });
                            else
                                btModel.append({
                                    "name": name,
                                    "mac": mac,
                                    "isActive": isActive
                                });
                        }
                    }
                }
            }
        }
    }

    ListModel {
        id: btModel
    }

    Column {
        anchors.fill: parent
        spacing: 16

        // --- HEADER ---
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
                    color: backArea.containsMouse ? Colors.bg2 : "transparent"
                    border.color: Colors.bg2
                    border.width: 1
                    Text {
                        anchors.centerIn: parent
                        text: "󰁍"
                        font.family: Config.fontName
                        font.pixelSize: 18
                        color: Colors.fg0
                    }
                    MouseArea {
                        id: backArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: btMenuRoot.backRequested()
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Bluetooth Devices"
                    font.family: Config.fontName
                    font.pixelSize: 16
                    font.bold: true
                    color: Colors.fg0
                }
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Rectangle {
                    width: 36
                    height: 36
                    radius: 18
                    color: scanArea.containsMouse ? Colors.bg2 : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "󰑐"
                        font.family: Config.fontName
                        font.pixelSize: 20
                        color: btMenuRoot.isScanning ? Colors.aqua : Colors.fg0

                        RotationAnimation on rotation {
                            loops: Animation.Infinite
                            from: 0
                            to: 360
                            duration: 1000
                            running: btMenuRoot.isScanning
                        }
                    }

                    MouseArea {
                        id: scanArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: toggleScan(!btMenuRoot.isScanning)
                    }
                }

                Item {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 44
                    height: 36

                    Rectangle {
                        anchors.centerIn: parent
                        width: 38
                        height: 22
                        radius: 11

                        color: btMenuRoot.isRadioOn ? (pwrArea.containsMouse ? Qt.rgba(Colors.aqua.r, Colors.aqua.g, Colors.aqua.b, 0.8) : Colors.aqua) : (pwrArea.containsMouse ? Colors.bg2 : Colors.bg1)

                        border.color: btMenuRoot.isRadioOn ? Colors.aqua : Colors.bg3
                        border.width: 1

                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                            }
                        }

                        Rectangle {
                            width: 14
                            height: 14
                            radius: 7
                            anchors.verticalCenter: parent.verticalCenter
                            x: btMenuRoot.isRadioOn ? parent.width - width - 4 : 4

                            color: btMenuRoot.isRadioOn ? Colors.bg0 : (pwrArea.containsMouse ? Colors.fg2 : Colors.fg3)

                            Behavior on x {
                                NumberAnimation {
                                    duration: 200
                                    easing.type: Easing.OutQuart
                                }
                            }
                            Behavior on color {
                                ColorAnimation {
                                    duration: 200
                                }
                            }
                        }
                    }

                    MouseArea {
                        id: pwrArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            btMenuRoot.isToggling = true;
                            toggleLockTimer.restart();

                            if (btMenuRoot.isRadioOn && btMenuRoot.isScanning) {
                                toggleScan(false);
                            }

                            let cmd = btMenuRoot.isRadioOn ? "bluetoothctl power off" : "bluetoothctl power on";
                            actionProc.command = ["bash", "-c", cmd];
                            actionProc.running = true;

                            btMenuRoot.isRadioOn = !btMenuRoot.isRadioOn;
                        }
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Colors.bg3
        }

        // --- BLUETOOTH LIST ---
        Flickable {
            width: parent.width
            height: parent.height - 69
            contentHeight: listCol.height
            clip: true
            interactive: true

            Column {
                id: listCol
                width: parent.width
                spacing: 8

                Repeater {
                    model: btModel
                    Rectangle {
                        id: btBox
                        width: parent.width
                        property bool isExpanded: btMenuRoot.expandedMac === model.mac

                        height: isExpanded ? 96 : 48
                        radius: 12
                        clip: true

                        color: model.isActive ? Colors.bg2 : (btMouseArea.containsMouse ? Colors.bg2 : Colors.bg1)
                        border.color: model.isActive ? Colors.aqua : (btMouseArea.containsMouse ? Colors.bg3 : Colors.bg2)
                        border.width: 1

                        Behavior on height {
                            NumberAnimation {
                                duration: 250
                                easing.type: Easing.OutQuart
                            }
                        }
                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }

                        Item {
                            width: parent.width
                            height: 48

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 16
                                anchors.right: statusBadge.visible ? statusBadge.left : parent.right
                                anchors.rightMargin: 16
                                text: model.name
                                font.family: Config.fontName
                                font.pixelSize: 14
                                font.bold: model.isActive
                                color: model.isActive ? Colors.aqua : Colors.fg0
                                elide: Text.ElideRight
                            }

                            Text {
                                id: statusBadge
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                anchors.rightMargin: 16
                                visible: model.isActive
                                text: "Connected"
                                color: Colors.aqua
                                font.family: Config.fontName
                                font.pixelSize: 12
                                font.bold: true
                            }

                            MouseArea {
                                id: btMouseArea
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onClicked: btMenuRoot.expandedMac = (btMenuRoot.expandedMac === model.mac) ? "" : model.mac
                            }
                        }

                        Item {
                            y: 48
                            width: parent.width
                            height: parent.height - 48
                            opacity: btBox.isExpanded ? 1 : 0
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 250
                                }
                            }

                            Row {
                                anchors.fill: parent
                                anchors.margins: 12
                                anchors.topMargin: 0
                                spacing: 12

                                Rectangle {
                                    width: (parent.width - 12) / 2
                                    height: 36
                                    radius: 8
                                    color: model.isActive ? (connArea.containsMouse ? Colors.bg3 : Colors.bg2) : (connArea.containsMouse ? Qt.rgba(Colors.aqua.r, Colors.aqua.g, Colors.aqua.b, 0.8) : Colors.aqua)
                                    border.color: model.isActive ? Colors.bg3 : Colors.aqua
                                    border.width: 1
                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 150
                                        }
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        text: model.isActive ? "Disconnect" : "Connect"
                                        color: model.isActive ? Colors.fg0 : Colors.bg0
                                        font.family: Config.fontName
                                        font.pixelSize: 13
                                        font.bold: true
                                    }

                                    MouseArea {
                                        id: connArea
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        hoverEnabled: true
                                        onClicked: {
                                            actionProc.running = false;
                                            let cmd = model.isActive ? "bluetoothctl disconnect '" + model.mac + "'" : "bluetoothctl pair '" + model.mac + "'; bluetoothctl trust '" + model.mac + "'; bluetoothctl connect '" + model.mac + "'";

                                            actionProc.command = ["bash", "-c", cmd];
                                            actionProc.running = true;
                                            btMenuRoot.expandedMac = "";
                                        }
                                    }
                                }

                                Rectangle {
                                    width: (parent.width - 12) / 2
                                    height: 36
                                    radius: 8
                                    color: forgetArea.containsMouse ? Qt.rgba(Colors.red.r, Colors.red.g, Colors.red.b, 0.8) : Colors.red
                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 150
                                        }
                                    }
                                    Text {
                                        anchors.centerIn: parent
                                        text: "Forget"
                                        color: Colors.bg0
                                        font.family: Config.fontName
                                        font.pixelSize: 13
                                        font.bold: true
                                    }

                                    MouseArea {
                                        id: forgetArea
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        hoverEnabled: true
                                        onClicked: {
                                            actionProc.running = false;
                                            actionProc.command = ["bash", "-c", "bluetoothctl remove '" + model.mac + "'"];
                                            actionProc.running = true;
                                            btMenuRoot.expandedMac = "";

                                            for (let j = 0; j < btModel.count; j++) {
                                                if (btModel.get(j).mac === model.mac) {
                                                    btModel.remove(j);
                                                    break;
                                                }
                                            }

                                            // THE FIX: Automatically jump-starts a scan right after forgetting a device
                                            // so it can instantly find it again when put in pairing mode!
                                            toggleScan(true);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
