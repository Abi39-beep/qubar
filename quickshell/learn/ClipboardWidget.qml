import QtQuick
import Quickshell
import Quickshell.Io
import "."

Rectangle {
    id: clipWidget
    width: 30; height: 30; radius: 15
    color: Colors.bg1 
    border.width: 1
    border.color: Colors.bg2

    Text {
        anchors.centerIn: parent
        text: "󰅌" 
        font.pixelSize: 15
        font.family: "JetBrainsMono Nerd Font"
        color: Colors.fg 
    }

    Timer {
        id: resetTimer
        interval: 10
        onTriggered: {
            refreshClip.command =["bash", "-c", "cliphist list #" + Date.now()];
            refreshClip.fullOutput = ""; 
            refreshClip.running = true;
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            clipPopup.visible = !clipPopup.visible
            if (clipPopup.visible) {
                refreshClip.running = false;
                resetTimer.start();
            }
        }
    }

    ListModel { id: clipModel }

    Process {
        id: refreshClip
        command: ["bash", "-c", "cliphist list"]
        property string fullOutput: ""
        
        stdout: SplitParser {
            onRead: data => { refreshClip.fullOutput += data + "\n"; }
        }
        
        onExited: {
            clipModel.clear();
            let lines = fullOutput.split("\n");
            fullOutput = ""; 
            
            let count = 0;
            for (let i = 0; i < lines.length; i++) {
                if (!lines[i].trim()) continue; 
                
                let sep = lines[i].indexOf('\t');
                if (sep !== -1) {
                    let id = lines[i].substring(0, sep);
                    let text = lines[i].substring(sep + 1);
                    
                    clipModel.append({ "clipId": id, "clipText": text });
                    
                    count++;
                    if (count >= 30) break; 
                }
            }
        }
    }

    PopupWindow {
        id: clipPopup
        anchor.item: clipWidget
        anchor.edges: Edges.Bottom | Edges.Left
        width: 280; height: 350 
        visible: false
        color: "transparent"
        grabFocus: true 
        
        onVisibleChanged: { if (visible) bgRect.forceActiveFocus() }

        Rectangle {
            id: bgRect
            anchors.fill: parent; anchors.topMargin: 10
            color: Colors.bg0; border.color: Colors.grey0; border.width: 1; radius: 8
            focus: true
            Keys.onEscapePressed: clipPopup.visible = false
            onActiveFocusChanged: { if (!activeFocus) clipPopup.visible = false }

            Column {
                anchors.fill: parent; anchors.margins: 10; spacing: 10

                Row {
                    width: parent.width
                    
                    Text { 
                        text: "Clipboard"
                        color: Colors.fg; font.bold: true; font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    Item { width: parent.width - 140; height: 1 } 
                    
                    Rectangle {
                        width: 70; height: 24; radius: 4
                        color: Colors.red
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Text { 
                            anchors.centerIn: parent
                            text: "󰆴 Clear" 
                            color: Colors.bg0; font.bold: true; font.pixelSize: 11; font.family: "JetBrainsMono Nerd Font"
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                Quickshell.execDetached(["cliphist", "wipe"]);
                                clipModel.clear(); 
                                clipPopup.visible = false;
                            }
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: Colors.bg2 } 

                ListView {
                    width: parent.width; height: 280
                    clip: true
                    model: clipModel
                    spacing: 6
                    
                    delegate: Item {
                        width: parent.width; height: 40
                        
                        Rectangle {
                            anchors.fill: parent
                            radius: 6
                            color: itemMouse.containsMouse ? Colors.bg2 : "transparent"
                        }

                        // Copy logic fixed with $'\t'
                        MouseArea {
                            id: itemMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                let cmd = "cliphist list | awk -F $'\\t' '$1 == \"" + model.clipId + "\"' | cliphist decode | wl-copy";
                                Quickshell.execDetached(["bash", "-c", cmd]);
                                clipPopup.visible = false;
                            }
                        }

                        Row {
                            anchors.fill: parent; anchors.margins: 6; spacing: 8
                            
                            Text {
                                text: model.clipText
                                color: Colors.fg
                                font.pixelSize: 12
                                width: parent.width - 64 
                                anchors.verticalCenter: parent.verticalCenter
                                elide: Text.ElideRight
                                maximumLineCount: 2
                                wrapMode: Text.Wrap
                            }
                            
                            // Copy Icon
                            Rectangle {
                                width: 26; height: 26; radius: 4
                                color: copyMouse.containsMouse ? Colors.blue : Colors.bg3
                                anchors.verticalCenter: parent.verticalCenter
                                
                                Text { anchors.centerIn: parent; text: "󰆏"; color: copyMouse.containsMouse ? Colors.bg0 : Colors.fg; font.pixelSize: 13; font.family: "JetBrainsMono Nerd Font" }
                                
                                MouseArea {
                                    id: copyMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        let cmd = "cliphist list | awk -F $'\\t' '$1 == \"" + model.clipId + "\"' | cliphist decode | wl-copy";
                                        Quickshell.execDetached(["bash", "-c", cmd]);
                                        clipPopup.visible = false;
                                    }
                                }
                            }

                            // Permanent Delete Icon fixed with $'\t'
                            Rectangle {
                                width: 26; height: 26; radius: 4
                                color: delMouse.containsMouse ? Colors.red : "transparent"
                                anchors.verticalCenter: parent.verticalCenter
                                
                                Text { anchors.centerIn: parent; text: "󰆴"; color: delMouse.containsMouse ? Colors.bg0 : Colors.grey1; font.pixelSize: 13; font.family: "JetBrainsMono Nerd Font" }
                                
                                MouseArea {
                                    id: delMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        let cmd = "cliphist list | awk -F $'\\t' '$1 == \"" + model.clipId + "\"' | cliphist delete";
                                        Quickshell.execDetached(["bash", "-c", cmd]);
                                        clipModel.remove(index);
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
