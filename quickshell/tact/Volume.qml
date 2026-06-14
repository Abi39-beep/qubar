import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Column {
    spacing: Config.ccSpacing
    width: parent.width

    // VOLUME SLIDER
    Rectangle {
        width: parent.width
        height: Config.ccSliderHeight
        radius: Config.ccSliderRadius
        color: Colors.bg0
        border.color: Colors.bg3
        border.width: 1

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.margins: 4
            radius: Config.ccSliderRadius - 4

            property real volTarget: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio.volume : 0.5
            width: Math.max(height, (parent.width - 8) * volTarget)
            color: Colors.aqua
            Behavior on width {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutQuad
                }
            }

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 12
                text: "󰕾"
                font.family: Config.fontName
                font.pixelSize: Config.fontSizeCcSliderIcon
                color: Colors.bg0
            }
        }
    }

    // BRIGHTNESS SLIDER
    Rectangle {
        width: parent.width
        height: Config.ccSliderHeight
        radius: Config.ccSliderRadius
        color: Colors.bg0
        border.color: Colors.bg3
        border.width: 1

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.margins: 4
            radius: Config.ccSliderRadius - 4

            width: (parent.width - 8) * 0.75
            color: Colors.aqua

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 12
                text: "󰃠"
                font.family: Config.fontName
                font.pixelSize: Config.fontSizeCcSliderIcon
                color: Colors.bg0
            }
        }
    }
}
