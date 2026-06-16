import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: wifiMenuRoot
    signal backRequested

    property string expandedSsid: ""
    property bool isRadioOn: false
    property bool isScanning: false

    onVisibleChanged: {
        if (!visible) {
            expandedSsid = "";
        } else {
            fetchDevicesProc.running = false;
            fetchDevicesProc.running = true;
        }
    }

    onIsRadioOnChanged: {
        if (!isRadioOn)
            networkModel.clear();
    }

    Process {
        id: radioProc
        command: ["bash", "-c", "nmcli radio wifi"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                wifiMenuRoot.isRadioOn = (data.trim() === "enabled");
            }
        }
    }
    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: radioProc.running = true
    }

    // --- SCANNER LOGIC ---
    Process {
        id: scanActionProc
        running: false
    }
    Timer {
        id: scanTimer
        interval: 10000
        onTriggered: wifiMenuRoot.isScanning = false
    }

    function toggleScan(start) {
        wifiMenuRoot.isScanning = start;
        if (start) {
            scanActionProc.command = ["bash", "-c", "nmcli dev wifi rescan"];
            scanActionProc.running = true;
            scanTimer.restart();
        } else {
            scanTimer.stop();
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

    // --- REAL-TIME SMART FETCHER ---
    Timer {
        interval: 3000
        running: wifiMenuRoot.visible
        repeat: true
        onTriggered: {
            fetchDevicesProc.running = false;
            fetchDevicesProc.running = true;
        }
    }

    Process {
        id: fetchDevicesProc
        command: ["bash", "-c", "val=$(nmcli -t -f ACTIVE,SIGNAL,SSID dev wifi list); echo \"${val:-NONE}\""]
        running: true

        stdout: SplitParser {
            onRead: data => {
                let res = data.trim();
                if (res === "NONE" || res === "")
                    return;

                let lines = res.split("\n");
                for (let i = 0; i < lines.length; i++) {
                    let line = lines[i].trim();
                    if (!line)
                        continue;

                    let firstColon = line.indexOf(":");
                    let secondColon = line.indexOf(":", firstColon + 1);

                    if (firstColon > -1 && secondColon > -1) {
                        let activeStr = line.substring(0, firstColon);
                        let isActive = (activeStr === "yes" || activeStr === "*");
                        let signal = parseInt(line.substring(firstColon + 1, secondColon)) || 0;
                        let ssid = line.substring(secondColon + 1);

                        if (ssid !== "") {
                            let found = false;
                            for (let j = 0; j < networkModel.count; j++) {
                                if (networkModel.get(j).ssid === ssid) {
                                    networkModel.setProperty(j, "signal", signal);
                                    if (networkModel.get(j).isActive !== isActive) {
                                        networkModel.setProperty(j, "isActive", isActive);

                                        if (isActive)
                                            networkModel.move(j, 0, 1);
                                        else
                                            networkModel.move(j, networkModel.count - 1, 1);
                                    }
                                    found = true;
                                    break;
                                }
                            }
                            if (!found) {
                                if (isActive)
                                    networkModel.insert(0, {
                                        "ssid": ssid,
                                        "signal": signal,
                                        "isActive": isActive
                                    });
                                else
                                    networkModel.append({
                                        "ssid": ssid,
                                        "signal": signal,
                                        "isActive": isActive
                                    });
                            }
                        }
                    }
                }
            }
        }
    }

    ListModel {
        id: networkModel
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
                        onClicked: wifiMenuRoot.backRequested()
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Wi-Fi Networks"
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
                        color: wifiMenuRoot.isScanning ? Colors.aqua : Colors.fg0

                        RotationAnimation on rotation {
                            loops: Animation.Infinite
                            from: 0
                            to: 360
                            duration: 1000
                            running: wifiMenuRoot.isScanning
                        }
                    }

                    MouseArea {
                        id: scanArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: toggleScan(!wifiMenuRoot.isScanning)
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

                        color: wifiMenuRoot.isRadioOn ? (pwrArea.containsMouse ? Qt.rgba(Colors.aqua.r, Colors.aqua.g, Colors.aqua.b, 0.8) : Colors.aqua) : (pwrArea.containsMouse ? Colors.bg2 : Colors.bg1)

                        border.color: wifiMenuRoot.isRadioOn ? Colors.aqua : Colors.bg3
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
                            x: wifiMenuRoot.isRadioOn ? parent.width - width - 4 : 4

                            color: wifiMenuRoot.isRadioOn ? Colors.bg0 : (pwrArea.containsMouse ? Colors.fg2 : Colors.fg3)

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
                            let cmd = wifiMenuRoot.isRadioOn ? "nmcli radio wifi off" : "nmcli radio wifi on";
                            actionProc.command = ["bash", "-c", cmd];
                            actionProc.running = true;
                            wifiMenuRoot.isRadioOn = !wifiMenuRoot.isRadioOn;
                        }
                    }
                }
            }
        }

        // --- SEPARATOR LINE ---
        Rectangle {
            width: parent.width
            height: 1
            color: Colors.bg3
        }

        // --- WI-FI LIST ---
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
                    model: networkModel
                    Rectangle {
                        id: netBox
                        width: parent.width
                        property bool isExpanded: wifiMenuRoot.expandedSsid === model.ssid

                        // THE FIX: Automatically clear password and reset eye icon when closing!
                        onIsExpandedChanged: {
                            if (!isExpanded) {
                                passInput.text = "";
                                passCol.showPass = false;
                            }
                        }

                        height: isExpanded ? (model.isActive ? 104 : 124) : 48
                        radius: 12
                        clip: true

                        color: model.isActive ? Colors.bg2 : (netMouseArea.containsMouse ? Colors.bg2 : Colors.bg1)
                        border.color: model.isActive ? Colors.aqua : (netMouseArea.containsMouse ? Colors.bg3 : Colors.bg2)
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

                        // 1. TOP ROW
                        Item {
                            width: parent.width
                            height: 48

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 16
                                anchors.right: statusBadge.visible ? statusBadge.left : parent.right
                                anchors.rightMargin: 16
                                text: model.ssid
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
                                id: netMouseArea
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onClicked: {
                                    if (wifiMenuRoot.expandedSsid === model.ssid) {
                                        wifiMenuRoot.expandedSsid = "";
                                    } else {
                                        wifiMenuRoot.expandedSsid = model.ssid;
                                        if (!model.isActive)
                                            passInput.forceActiveFocus();
                                    }
                                }
                            }
                        }

                        // 2. EXPANDED ACTION AREA
                        Item {
                            y: 48
                            width: parent.width
                            height: parent.height - 48
                            opacity: netBox.isExpanded ? 1 : 0
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 250
                                }
                            }

                            // A. PASSWORD BOX
                            Column {
                                id: passCol // Given an ID so it can be reset!
                                anchors.fill: parent
                                anchors.margins: 12
                                anchors.topMargin: 0
                                spacing: 8
                                visible: !model.isActive

                                property bool showPass: false

                                Rectangle {
                                    width: parent.width
                                    height: 36
                                    radius: 8
                                    color: "transparent"
                                    border.color: Colors.aqua
                                    border.width: 1

                                    TextInput {
                                        id: passInput
                                        anchors.left: parent.left
                                        anchors.right: eyeBtn.left
                                        anchors.top: parent.top
                                        anchors.bottom: parent.bottom
                                        anchors.leftMargin: 10
                                        anchors.rightMargin: 10
                                        verticalAlignment: TextInput.AlignVCenter

                                        color: Colors.fg0
                                        font.family: Config.fontName
                                        font.pixelSize: 14
                                        echoMode: passCol.showPass ? TextInput.Normal : TextInput.Password
                                        clip: true

                                        Keys.onEscapePressed: {
                                            wifiMenuRoot.expandedSsid = "";
                                            ccRoot.forceActiveFocus();
                                        }

                                        onAccepted: {
                                            actionProc.command = ["bash", "-c", "nmcli dev wifi connect '" + model.ssid + "' password '" + passInput.text + "'"];
                                            actionProc.running = true;
                                            wifiMenuRoot.expandedSsid = "";
                                            ccRoot.forceActiveFocus();
                                        }
                                    }

                                    Text {
                                        id: eyeBtn
                                        anchors.right: parent.right
                                        anchors.rightMargin: 10
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: passCol.showPass ? "󰈈" : "󰈉"
                                        font.family: Config.fontName
                                        font.pixelSize: 16
                                        color: eyeArea.containsMouse ? Colors.aqua : Colors.fg3

                                        MouseArea {
                                            id: eyeArea
                                            anchors.fill: parent
                                            anchors.margins: -5
                                            cursorShape: Qt.PointingHandCursor
                                            hoverEnabled: true
                                            onClicked: {
                                                passCol.showPass = !passCol.showPass;
                                                passInput.forceActiveFocus();
                                            }
                                        }
                                    }
                                }
                                Text {
                                    text: "Press Enter to connect."
                                    font.family: Config.fontName
                                    font.pixelSize: 11
                                    color: Colors.fg3
                                }
                            }

                            // B. DISCONNECT / FORGET BUTTONS
                            Row {
                                anchors.fill: parent
                                anchors.margins: 12
                                anchors.topMargin: 4
                                spacing: 12
                                visible: model.isActive

                                Rectangle {
                                    width: (parent.width - 12) / 2
                                    height: 36
                                    radius: 8
                                    color: connArea.containsMouse ? Colors.bg3 : Colors.bg2
                                    border.color: Colors.bg3
                                    border.width: 1
                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 150
                                        }
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        text: "Disconnect"
                                        color: Colors.fg0
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
                                            actionProc.command = ["bash", "-c", "nmcli con down id '" + model.ssid + "'"];
                                            actionProc.running = true;
                                            wifiMenuRoot.expandedSsid = "";
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
                                            actionProc.command = ["bash", "-c", "nmcli con delete id '" + model.ssid + "'"];
                                            actionProc.running = true;
                                            wifiMenuRoot.expandedSsid = "";

                                            for (let j = 0; j < networkModel.count; j++) {
                                                if (networkModel.get(j).ssid === model.ssid) {
                                                    networkModel.remove(j);
                                                    break;
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
    }
}
