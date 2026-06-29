import Quickshell.Io
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root
    spacing: 7

    property bool ready: false
    property int level: 0

    property int maxLevel: 100
    property string backlightPath: ""

    Process {
        id: initProc
        command: ["bash", "-c", "ls -1 /sys/class/backlight | head -n 1"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                let dir = data.trim();
                if (dir !== "") {
                    root.backlightPath = "/sys/class/backlight/" + dir;
                }
            }
        }
    }

    FileView {
        id: maxFile
        path: root.backlightPath !== "" ? root.backlightPath + "/max_brightness" : ""

        onLoaded: {
            let val = parseInt(maxFile.text().trim());
            if (!isNaN(val)) {
                root.maxLevel = val;
                if (brightFile.loaded)
                    brightFile.reload();
            }
        }
    }

    FileView {
        id: brightFile
        path: root.backlightPath !== "" ? root.backlightPath + "/actual_brightness" : ""
        watchChanges: true
        onFileChanged: brightFile.reload()

        onLoaded: {
            let val = parseInt(brightFile.text().trim());
            if (!isNaN(val) && root.maxLevel > 0) {
                root.level = Math.round((val / root.maxLevel) * 100);
                root.ready = true;
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
