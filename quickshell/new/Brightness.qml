import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root
    spacing: 7

    property bool ready: false
    property int level: 0

    Process {
        id: brightProc
        running: true
        command: ["sh", "-c", "while true; do brightnessctl -m | awk -F, '{print int($4)}'; inotifywait -qq -e modify /sys/class/backlight/*/brightness; done"]

        stdout: SplitParser {
            onRead: data => {
                var val = parseInt(data.trim());
                if (!isNaN(val)) {
                    root.level = val;
                    root.ready = true;
                }
            }
        }
    }

    readonly property string icon: {
        if (!ready)
            return String.fromCodePoint(0xF00DA);

        if (level === 0)
            return String.fromCodePoint(0xF00DB);
        if (level < 30)
            return String.fromCodePoint(0xF00DE);
        if (level < 60)
            return String.fromCodePoint(0xF00DF);

        return String.fromCodePoint(0xF00E0);
    }

    Text {
        text: root.icon
        color: Colors.orange

        font {
            family: "JetBrainsMono Nerd Font Propo"
            pixelSize: 16
        }
    }

    Text {
        text: {
            if (!root.ready)
                return "_";

            return root.level + "%";
        }

        color: Colors.fg

        font {
            family: "SF Pro Display Light"
            weight: 700
        }
    }
}
