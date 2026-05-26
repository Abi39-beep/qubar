import QtQuick
import Quickshell
import Quickshell.Io
import "../.."

Item {
    anchors.fill: parent
    ListModel { id: clipModel }
    
    Timer { id: resetTimer; interval: 10; onTriggered: { refreshClip.command = ["bash", "-c", "cliphist list #" + Date.now()]; refreshClip.fullOutput = ""; refreshClip.running = true; } }
    
    Process {
        id: refreshClip; command: ["bash", "-c", "cliphist list"]; property string fullOutput: ""
        stdout: SplitParser { onRead: data => { refreshClip.fullOutput += data + "\n"; } }
        onExited: {
            clipModel.clear(); let lines = fullOutput.split("\n"); let count = 0;
            for (let i = 0; i < lines.length; i++) {
                let sep = lines[i].indexOf('\t');
                if (sep !== -1) { clipModel.append({ "clipId": lines[i].substring(0, sep), "clipText": lines[i].substring(sep + 1), "justCopied": false }); if (++count >= 30) break; }
            }
        }
    }

    Component.onCompleted: resetTimer.start()

    Rectangle {
        width: 70; height: 24; radius: 4; color: Colors.red; anchors.top: parent.top; anchors.right: parent.right; z: 2
        Text { anchors.centerIn: parent; text: "󰆴 Clear"; color: Colors.bg0; font.bold: true; font.pixelSize: 11 }
        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { Quickshell.execDetached(["cliphist", "wipe"]); clipModel.clear(); } }
    }

    ListView {
        anchors.fill: parent; anchors.topMargin: 34; clip: true; spacing: 6; model: clipModel
        delegate: Item {
            width: parent.width; height: 40
            Rectangle { anchors.fill: parent; radius: 6; color: itemMouse.containsMouse ? Colors.bg2 : "transparent" }
            MouseArea { id: itemMouse; anchors.fill: parent; hoverEnabled: true; onClicked: { Quickshell.execDetached(["bash", "-c", "cliphist list | awk -F $'\\t' '$1 == \"" + model.clipId + "\"' | cliphist decode | wl-copy"]); } }
            Row {
                anchors.fill: parent; anchors.margins: 6; spacing: 8
                Text { text: model.clipText; color: Colors.fg; font.pixelSize: 12; width: parent.width - 68; elide: Text.ElideRight; anchors.verticalCenter: parent.verticalCenter }
                Rectangle { width: 26; height: 26; radius: 4; color: Colors.bg3; Text { anchors.centerIn: parent; text: "󰆏"; color: Colors.fg; font.family: "JetBrainsMono Nerd Font" } }
                Rectangle { width: 26; height: 26; radius: 4; color: "transparent"; Text { anchors.centerIn: parent; text: "󰆴"; color: Colors.grey1; font.family: "JetBrainsMono Nerd Font" } MouseArea { anchors.fill: parent; onClicked: { Quickshell.execDetached(["bash", "-c", "cliphist list | awk -F $'\\t' '$1 == \"" + model.clipId + "\"' | cliphist delete"]); clipModel.remove(index); } } }
            }
        }
    }
}
