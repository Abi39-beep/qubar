pragma ComponentBehavior: Bound
import QtQuick

Item {
    id: visualizer

    width: (Config.eqBarCount * Config.eqBarWidth) + ((Config.eqBarCount - 1) * Config.eqBarSpacing)
    height: Config.eqMaxHeight

    property bool isPlaying: false

    Row {
        anchors.fill: parent
        spacing: Config.eqBarSpacing

        Repeater {
            id: eqRepeater
            model: Config.eqBarCount

            Rectangle {
                id: bar
                width: Config.eqBarWidth
                height: Config.eqMinHeight
                radius: width / 2
                color: Colors.aqua

                anchors.bottom: parent.bottom

                Behavior on height {
                    NumberAnimation {
                        duration: animTimer.interval
                        easing.type: Easing.InOutQuad
                    }
                }

                Timer {
                    id: animTimer
                    running: visualizer.isPlaying
                    repeat: true

                    interval: Config.eqAnimDuration

                    onRunningChanged: {
                        if (running) {
                            triggered();
                        } else {
                            bar.height = Config.eqMinHeight;
                        }
                    }

                    onTriggered: {
                        if (visualizer.isPlaying) {
                            animTimer.interval = Config.eqAnimDuration + (Math.random() * 50);
                            bar.height = Math.max(Config.eqMinHeight, Math.random() * Config.eqMaxHeight);
                        }
                    }
                }
            }
        }
    }
}
