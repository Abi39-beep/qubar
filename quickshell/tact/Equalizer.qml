import QtQuick

Item {
    id: visualizer

    // Explicit bounds ensure the PillBar layout doesn't crush the EQ to 0 width
    width: (Config.eqBarCount * Config.eqBarWidth) + ((Config.eqBarCount - 1) * Config.eqBarSpacing)
    height: Config.eqMaxHeight

    property bool isPlaying: false

    onIsPlayingChanged: {
        if (!isPlaying) {
            for (let i = 0; i < eqRepeater.count; i++) {
                if (eqRepeater.itemAt(i)) {
                    eqRepeater.itemAt(i).height = Config.eqMinHeight;
                }
            }
        }
    }

    Row {
        anchors.fill: parent
        spacing: Config.eqBarSpacing

        Repeater {
            id: eqRepeater
            model: Config.eqBarCount

            Rectangle {
                width: Config.eqBarWidth
                height: Config.eqMinHeight
                radius: width / 2
                color: Colors.aqua

                // Anchoring to the bottom forces the bars to grow UPWARDS
                anchors.bottom: parent.bottom

                Behavior on height {
                    NumberAnimation {
                        duration: Config.eqAnimDuration
                        easing.type: Easing.InOutQuad
                    }
                }

                Timer {
                    running: visualizer.isPlaying
                    repeat: true
                    // Stagger the bounce timing slightly
                    interval: Config.eqAnimDuration + (Math.random() * 50)

                    onTriggered: {
                        if (visualizer.isPlaying) {
                            parent.height = Math.max(Config.eqMinHeight, Math.random() * Config.eqMaxHeight);
                        } else {
                            parent.height = Config.eqMinHeight;
                        }
                    }
                }
            }
        }
    }
}
