import Quickshell
import QtQuick

Text {
    text: Qt.formatDateTime(clock.date, "hh:mm")
    color: Colors.aqua

    font {
        family: "SF Mono Light"
        letterSpacing: -0.5
        pixelSize: 15
        weight: 700
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
