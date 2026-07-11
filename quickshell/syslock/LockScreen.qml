pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

WlSessionLock {
    id: sessionLock

    property bool isLocked: false
    locked: isLocked
    property url currentWall: ""

    WlSessionLockSurface {
        color: Colors.bg0

        Process {
            id: readWallProc
            command: ["cat", Quickshell.env("HOME") + "/.cache/current_wallpaper"]

            running: sessionLock.isLocked

            stdout: SplitParser {
                onRead: data => {
                    let path = data.trim();
                    if (path !== "") {
                        // Formats the text into a proper URL and applies it to the image
                        sessionLock.currentWall = path.startsWith("file:") ? path : "file:///" + path.replace(/^\/+/, "");
                    }
                }
            }
        }

        Image {
            anchors.fill: parent
            source: sessionLock.currentWall
            fillMode: Image.PreserveAspectCrop
            cache: false
        }

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.6)
        }

        Column {
            anchors.centerIn: parent
            spacing: 24

            Text {
                id: clockText
                text: Qt.formatDateTime(clock.date, "hh:mm")
                color: Colors.fg0
                font {
                    family: "SF Pro Display"
                    pixelSize: 96
                    bold: true
                }
                anchors.horizontalCenter: parent.horizontalCenter

                SystemClock {
                    id: clock
                    precision: SystemClock.Minutes
                }
            }

            Text {
                text: Quickshell.env("USER")
                color: Colors.fg1
                font {
                    family: "SF Pro Display"
                    pixelSize: 20
                    bold: true
                }
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Rectangle {
                width: 300
                height: 48
                radius: 24
                color: Colors.bg1
                border.color: Colors.bg2
                border.width: 2
                anchors.horizontalCenter: parent.horizontalCenter

                TextInput {
                    id: pwdInput
                    anchors.fill: parent
                    anchors.margins: 12
                    verticalAlignment: TextInput.AlignVCenter
                    horizontalAlignment: TextInput.AlignHCenter
                    color: Colors.fg0
                    font.pixelSize: 18
                    echoMode: TextInput.Password
                    focus: true

                    onAccepted: {
                        authProc.running = false;
                        authProc.command = ["python3", "-c", "import pam, sys; print('SUCCESS') if pam.authenticate(sys.argv[1], sys.argv[2]) else print('FAIL')", Quickshell.env("USER"), pwdInput.text];
                        pwdInput.text = "";
                        authProc.running = true;
                    }
                }
            }
        }

        Process {
            id: authProc
            command: []

            stdout: SplitParser {
                onRead: data => {
                    if (data.trim() === "SUCCESS") {
                        sessionLock.isLocked = false;
                    } else {
                        pwdInput.forceActiveFocus();
                    }
                }
            }
        }
    }
}
