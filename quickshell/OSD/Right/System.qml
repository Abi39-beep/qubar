import QtQuick
import Quickshell
import Quickshell.Io
import ".."

Row {
    id: sysRoot
    
    // FIX 1: Gave it a defined height so it doesn't collapse to 0 and turn invisible
    height: 50 
    spacing: 10

    property string cpuUsage: "0.0%"
    property string memUsage: "0 MB"

    Timer {
        interval: 2000
        running: sysRoot.visible
        repeat: true
        onTriggered: {
            cpuPoll.running = true
            memPoll.running = true
        }
    }

    Process {
        id: cpuPoll
        command:[
            "bash", 
            "-c", 
            "top -bn1 | grep 'Cpu(s)' | awk '{print $2 + $4}'"
        ]
        stdout: SplitParser {
            onRead: data => {
                if (data.trim() !== "") {
                    sysRoot.cpuUsage = parseFloat(data).toFixed(1) + "%"
                }
            }
        }
    }

    Process {
        id: memPoll
        command:[
            "bash", 
            "-c", 
            "free -m | awk '/Mem:/ { if($3 < 1024) printf \"%d MB\", $3; else printf \"%.1f GB\", $3/1024 }'"
        ]
        stdout: SplitParser {
            onRead: data => {
                if (data.trim() !== "") {
                    sysRoot.memUsage = data.trim()
                }
            }
        }
    }

    Rectangle {
        // FIX 2: Dynamically calculate half of the parent width minus the 10px spacing
        width: (sysRoot.width - 10) / 2
        height: sysRoot.height
        radius: 10
        color: Colors.bg1
        border.width: 1
        border.color: Colors.bg2
        
        Row {
            anchors.centerIn: parent
            spacing: 8
            Text {
                text: "󰻠"
                color: Colors.aqua
                font.pixelSize: 18
                font.family: "JetBrainsMono Nerd Font"
                anchors.verticalCenter: parent.verticalCenter
            }
            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2
                Text { 
                    text: "CPU"
                    color: Colors.grey1
                    font.pixelSize: 10
                    font.bold: true 
                }
                Text { 
                    text: sysRoot.cpuUsage
                    color: Colors.fg
                    font.pixelSize: 12
                    font.bold: true 
                }
            }
        }
    }
    
    Rectangle {
        // FIX 2: Dynamically calculate half of the parent width minus the 10px spacing
        width: (sysRoot.width - 10) / 2
        height: sysRoot.height
        radius: 10
        color: Colors.bg1
        border.width: 1
        border.color: Colors.bg2
        
        Row {
            anchors.centerIn: parent
            spacing: 8
            Text {
                text: "󰍛"
                color: Colors.orange
                font.pixelSize: 18
                font.family: "JetBrainsMono Nerd Font"
                anchors.verticalCenter: parent.verticalCenter
            }
            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2
                Text { 
                    text: "Memory"
                    color: Colors.grey1
                    font.pixelSize: 10
                    font.bold: true 
                }
                Text { 
                    text: sysRoot.memUsage
                    color: Colors.fg
                    font.pixelSize: 12
                    font.bold: true 
                }
            }
        }
    }
}
