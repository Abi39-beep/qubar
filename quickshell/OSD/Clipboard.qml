import QtQuick
import Quickshell
import Quickshell.Io
import "."

Item {
    id: clipRoot
    anchors.fill: parent

    ListModel { 
        id: clipModel 
    }
    
    Process {
        id: refreshClip
        command:[ 
            "bash", 
            "-c", 
            "cliphist list" 
        ]
        property string fullOutput: ""
        stdout: SplitParser { 
            onRead: data => { 
                refreshClip.fullOutput += data + "\n" 
            } 
        }
        onExited: {
            clipModel.clear()
            let lines = fullOutput.split("\n")
            fullOutput = ""
            for (let i = 0; i < lines.length; i++) {
                let sep = lines[i].indexOf('\t')
                if (sep !== -1 && clipModel.count < 30) {
                    clipModel.append({ 
                        "clipId": lines[i].substring(0, sep), 
                        "clipText": lines[i].substring(sep + 1),
                        // FIX: Added the tracking property for the checkmark
                        "justCopied": false 
                    })
                }
            }
        }
    }

    Timer {
        interval: 2000
        running: clipRoot.visible
        repeat: true
        onTriggered: {
            refreshClip.running = true
        }
    }

    Component.onCompleted: {
        refreshClip.running = true
    }

    Rectangle {
        width: 80
        height: 28
        radius: 6
        color: Colors.red
        anchors.top: parent.top
        anchors.right: parent.right
        z: 2
        
        Item {
            anchors.centerIn: parent
            width: childrenRect.width
            height: childrenRect.height
            
            Text { 
                id: clearIconClip
                text: "󰆴"
                color: Colors.bg0
                font.pixelSize: 13
                font.family: "JetBrainsMono Nerd Font" 
                anchors.verticalCenter: clearTextClip.verticalCenter 
                anchors.verticalCenterOffset: 1 
            }
            Text { 
                id: clearTextClip
                anchors.left: clearIconClip.right
                anchors.leftMargin: 6
                text: "Clear"
                color: Colors.bg0
                font.bold: true
                font.pixelSize: 12 
            } 
        }
        
        MouseArea { 
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: { 
                Quickshell.execDetached(["cliphist", "wipe"])
                clipModel.clear()
            } 
        }
    }
    
    ListView {
        anchors.fill: parent
        anchors.topMargin: 40
        clip: true
        spacing: 8
        model: clipModel
        
        delegate: Rectangle {
            width: ListView.view ? ListView.view.width : 350
            height: 40
            radius: 8
            color: Colors.bg1
            border.color: Colors.bg2
            border.width: 1

            // FIX: Timer to reset the checkmark back to normal after 1.5 seconds
            Timer { 
                id: copySuccessTimer 
                interval: 1500 
                onTriggered: {
                    if (index >= 0 && index < clipModel.count) {
                        clipModel.setProperty(index, "justCopied", false)
                    }
                }
            }
            
            Row {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 10
                
                Text { 
                    text: model.clipText
                    color: Colors.fg
                    font.pixelSize: 12
                    width: parent.width - 70
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    anchors.verticalCenter: parent.verticalCenter 
                }
                
                // COPY BUTTON
                Rectangle {
                    width: 24
                    height: 24
                    radius: 4
                    // FIX: Transparent if ticked, else Blue if hovered, else normal background
                    color: model.justCopied ? "transparent" : (copyMouse.containsMouse ? Colors.blue : Colors.bg3)
                    anchors.verticalCenter: parent.verticalCenter
                    
                    Behavior on color { 
                        ColorAnimation { 
                            duration: 150 
                        } 
                    }
                    
                    Text { 
                        anchors.centerIn: parent
                        // FIX: Shows the Checkmark (󰄬) if copied, otherwise Copy Icon (󰆏)
                        text: model.justCopied ? "󰄬" : "󰆏"
                        // FIX: Turns Green if copied, Dark if hovered, Normal if idle
                        color: model.justCopied ? Colors.green : (copyMouse.containsMouse ? Colors.bg0 : Colors.fg)
                        font.pixelSize: 13
                        font.family: "JetBrainsMono Nerd Font" 
                        scale: copyMouse.containsMouse ? 1.1 : 1.0
                        
                        Behavior on scale { 
                            NumberAnimation { 
                                duration: 150
                                easing.type: Easing.OutBack 
                            } 
                        }
                    }
                    
                    MouseArea { 
                        id: copyMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { 
                            Quickshell.execDetached([
                                "bash", 
                                "-c", 
                                "cliphist list | awk -F $'\\t' '$1 == \"" + model.clipId + "\"' | cliphist decode | wl-copy"
                            ])
                            
                            // FIX: Triggers the checkmark UI and starts the timer
                            clipModel.setProperty(index, "justCopied", true)
                            copySuccessTimer.restart()
                        } 
                    }
                }
                
                // DELETE BUTTON
                Rectangle {
                    width: 24
                    height: 24
                    radius: 4
                    color: delMouse.containsMouse ? Colors.red : "transparent"
                    anchors.verticalCenter: parent.verticalCenter
                    
                    Behavior on color { 
                        ColorAnimation { 
                            duration: 150 
                        } 
                    }
                    
                    Text { 
                        anchors.centerIn: parent
                        text: "󰆴"
                        color: delMouse.containsMouse ? Colors.bg0 : Colors.red
                        font.pixelSize: 13
                        font.family: "JetBrainsMono Nerd Font" 
                        rotation: delMouse.containsMouse ? 15 : 0
                        
                        Behavior on rotation { 
                            NumberAnimation { 
                                duration: 150 
                            } 
                        }
                    }
                    
                    MouseArea { 
                        id: delMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { 
                            Quickshell.execDetached([
                                "bash", 
                                "-c", 
                                "cliphist list | awk -F $'\\t' '$1 == \"" + model.clipId + "\"' | cliphist delete"
                            ])
                            clipModel.remove(index)
                        } 
                    }
                }
            }
        }
    }
}
