import QtQuick
import ".."

Column {
    width: parent ? parent.width : 380
    spacing: 5
    
    Text {
        id: timeDisplay
        text: Qt.formatDateTime(new Date(), "hh:mm AP")
        color: Colors.fg
        font.pixelSize: 42
        font.bold: true
        font.family: "JetBrainsMono Nerd Font"
        anchors.horizontalCenter: parent.horizontalCenter
    }
    
    Text {
        id: dateDisplay
        text: Qt.formatDateTime(new Date(), "dddd, MMMM d")
        color: Colors.blue
        font.pixelSize: 18
        font.family: "JetBrainsMono Nerd Font"
        anchors.horizontalCenter: parent.horizontalCenter
    }
    
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var now = new Date()
            timeDisplay.text = Qt.formatDateTime(now, "hh:mm AP")
            dateDisplay.text = Qt.formatDateTime(now, "dddd, MMMM d")
        }
    }
}
