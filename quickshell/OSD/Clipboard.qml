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
                        "clipText": lines[i].substring(sep + 1) 
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
        
        Row { 
            anchors.centerIn: parent
            spacing: 6
            Text { 
                text: "󰆴"
                color: Colors.bg0
                font.pixelSize: 12
                font.family: "JetBrainsMono Nerd Font" 
                anchors.verticalCenter: parent.verticalCenter // FIX: Perfect Alignment
            }
            Text { 
                text: "Clear"
                color: Colors.bg0
                font.bold: true
                font.pixelSize: 12 
                anchors.verticalCenter: parent.verticalCenter // FIX: Perfect Alignment
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
                
                Rectangle {
                    width: 24
                    height: 24
                    radius: 4
                    color: Colors.bg3
                    anchors.verticalCenter: parent.verticalCenter
                    Text { 
                        anchors.centerIn: parent
                        text: "󰆏"
                        color: Colors.fg
                        font.pixelSize: 13
                        font.family: "JetBrainsMono Nerd Font" 
                    }
                    MouseArea { 
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { 
                            Quickshell.execDetached([
                                "bash", 
                                "-c", 
                                "cliphist list | awk -F $'\\t' '$1 == \"" + model.clipId + "\"' | cliphist decode | wl-copy"
                            ])
                        } 
                    }
                }
                
                Rectangle {
                    width: 24
                    height: 24
                    radius: 4
                    color: "transparent"
                    anchors.verticalCenter: parent.verticalCenter
                    Text { 
                        anchors.centerIn: parent
                        text: "󰆴"
                        color: Colors.red
                        font.pixelSize: 13
                        font.family: "JetBrainsMono Nerd Font" 
                    }
                    MouseArea { 
                        anchors.fill: parent
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
