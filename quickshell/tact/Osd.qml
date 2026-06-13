import QtQuick
import Quickshell

Item {
    id: osdRoot

    property real percentage: 0.5
    property string icon: "󰃠"
    property color iconColor: Colors.orange
    property color barColor: Colors.green

    Item {
        anchors.fill: parent
        anchors.leftMargin: Config.osdMargin
        anchors.rightMargin: Config.osdMargin

        Text {
            id: iconText
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: osdRoot.icon
            color: osdRoot.iconColor
            font.pixelSize: Config.fontSizeOsdIcon
            font.family: "JetBrainsMono Nerd Font"
            width: Config.osdIconWidth
            horizontalAlignment: Text.AlignLeft
        }

        Text {
            id: percentText
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: Math.round(osdRoot.percentage * 100) + "%"
            color: Colors.fg0
            font.pixelSize: Config.fontSizeOsdText
            font.bold: true
            font.family: "JetBrainsMono Nerd Font"
            width: Config.osdTextWidth
            horizontalAlignment: Text.AlignRight
        }

        Rectangle {
            anchors.left: iconText.right
            anchors.right: percentText.left
            anchors.leftMargin: Config.osdSpacing
            anchors.rightMargin: Config.osdSpacing
            anchors.verticalCenter: parent.verticalCenter

            height: Config.osdBarHeight
            radius: Config.osdBarHeight / 2
            color: Colors.bg2

            Rectangle {
                height: parent.height
                radius: Config.osdBarHeight / 2
                width: parent.width * Math.max(0, Math.min(1, osdRoot.percentage))
                color: osdRoot.barColor

                // --- THE FIX IS HERE ---
                Behavior on width {
                    // Only animate if the OSD is fully visible on screen!
                    // Otherwise, snap instantly to the correct percentage.
                    enabled: osdRoot.opacity === 1
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutQuad
                    }
                }
            }
        }
    }
}
