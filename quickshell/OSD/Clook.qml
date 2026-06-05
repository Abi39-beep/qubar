import QtQuick
import Quickshell

PanelWindow {
    id: clook

    // POSITIONING
    anchors {
        top: true
        left: false
        right: false
    }

    exclusiveZone: 0
    aboveWindows: true
    color: "transparent"

    width: 140
    height: 40

    // State variables
    property bool isVisible: false

    // NEW: A property that holds our formatted time string
    property string currentTime: Qt.formatTime(new Date(), "hh:mm AP")

    // NEW: This timer updates the currentTime property every 1 second (1000 ms)
    Timer {
        id: clockTimer
        interval: 1000
        running: true  // Start immediately
        repeat: true   // Keep looping forever
        onTriggered: {
            clook.currentTime = Qt.formatTime(new Date(), "hh:mm AP");
        }
    }

    Timer {
        id: hideTimer
        interval: 3000
        onTriggered: clook.isVisible = false
    }

    MouseArea {
        id: triggerZone
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        width: 350
        height: 20
        hoverEnabled: true

        onEntered: {
            clook.isVisible = true;
            hideTimer.restart();
        }
        onExited: {
            hideTimer.restart();
        }
    }

    Rectangle {
        id: notchBase
        width: parent.width
        property int cornerRadius: 12
        height: 40 + cornerRadius

        y: clook.isVisible ? -cornerRadius : -height

        Behavior on y {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutExpo
            }
        }

        color: Colors.bg1
        radius: cornerRadius

        Text {
            anchors.top: parent.top
            anchors.topMargin: notchBase.cornerRadius
            anchors.horizontalCenter: parent.horizontalCenter
            height: 40
            verticalAlignment: Text.AlignVCenter

            color: Colors.fg
            font.family: "Rubik Regular"
            font.pixelSize: 18
            font.bold: true

            // FIX: Point the text to the property being updated by the Timer
            text: clook.currentTime
        }
    }
}
