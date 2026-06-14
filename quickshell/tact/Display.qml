import QtQuick

Rectangle {
    id: root
    height: Config.ccToggleHeight
    radius: Config.ccToggleRadius
    color: Colors.bg0
    border.color: Colors.bg3
    border.width: 1

    Row {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 16
        spacing: 12

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "󰍹"
            font.family: Config.fontName
            font.pixelSize: Config.fontSizeCcToggleIcon
            color: Colors.fg0
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
            Text {
                text: "Display"
                font.family: Config.fontName
                font.pixelSize: Config.fontSizeCcToggleTitle
                font.bold: true
                color: Colors.fg0
            }
            Text {
                text: "Scale 1.25x"
                font.family: Config.fontName
                font.pixelSize: Config.fontSizeCcToggleSub
                color: Colors.fg3
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: parent.opacity = 0.8
        onExited: parent.opacity = 1.0
    }
}
