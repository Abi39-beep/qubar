import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Io
import ".."

Rectangle {
    id: root

    width: parent ? parent.width : 400
    height: 130
    radius: 12
    color: Colors.bg1
    border.color: Colors.bg2
    border.width: 1
    clip: true

    property MprisPlayer player: null
    readonly property bool hasPlayer: player !== null
    readonly property bool isPlaying: hasPlayer && player.playbackState === MprisPlaybackState.Playing

    readonly property string _title: hasPlayer && player.trackTitle ? player.trackTitle : "No Media"
    readonly property string _artist: hasPlayer && player.trackArtist ? player.trackArtist : ""
    readonly property string _identity: hasPlayer && player.identity ? player.identity : ""
    readonly property string _artUrl: hasPlayer && player.trackArtUrl ? resolveArtUrl(player.trackArtUrl) : ""

    property real _length: 0
    property real _position: 0

    function formatTime(totalSeconds) {
        if (totalSeconds <= 0 || isNaN(totalSeconds))
            return "0:00";
        let mins = Math.floor(totalSeconds / 60);
        let secs = Math.floor(totalSeconds % 60);
        return mins + ":" + (secs < 10 ? "0" : "") + secs;
    }

    function resolveArtUrl(url) {
        if (!url)
            return "";
        var s = url.toString();
        if (s.indexOf("http") === 0 || s.indexOf("file") === 0)
            return s;
        return "file://" + s;
    }

    Process {
        id: syncTime
        command: ["bash", "-c", "echo $(playerctl metadata --format '{{mpris:length}}') $(playerctl position)"]
        stdout: SplitParser {
            onRead: data => {
                let parts = data.trim().split(" ");
                if (parts.length >= 2) {
                    let rawLen = parseFloat(parts[0]);
                    let rawPos = parseFloat(parts[1]);
                    if (!isNaN(rawLen))
                        root._length = rawLen / 1000000;
                    if (!isNaN(rawPos))
                        root._position = rawPos;
                }
            }
        }
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: {
            let players = Mpris.players.values;
            let best = null;
            for (let i = 0; i < players.length; i++) {
                if (players[i] && players[i].playbackState === MprisPlaybackState.Playing) {
                    best = players[i];
                    break;
                }
                if (players[i] && !best)
                    best = players[i];
            }
            root.player = best;
            if (root.hasPlayer)
                syncTime.running = true;
        }
    }

    Row {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        Rectangle {
            width: 105
            height: 105
            radius: 10
            color: Colors.bg2
            clip: true
            anchors.verticalCenter: parent.verticalCenter
            Image {
                anchors.fill: parent
                source: root._artUrl
                fillMode: Image.PreserveAspectCrop
                smooth: true
            }
            Text {
                anchors.centerIn: parent
                text: "\uf001"
                color: Colors.grey1
                font.pixelSize: 32
                font.family: "JetBrainsMono Nerd Font"
                visible: !root._artUrl
            }
        }

        Column {
            width: parent.width - 129
            height: 105
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0

            Item {
                width: parent.width
                height: 44
                Column {
                    anchors.left: parent.left
                    anchors.right: playerIcon.left
                    anchors.rightMargin: 5
                    Text {
                        text: root._title
                        color: Colors.fg
                        font.pixelSize: 17
                        font.bold: true
                        elide: Text.ElideRight
                        width: parent.width
                    }
                    Text {
                        text: root._artist
                        color: Colors.grey1
                        font.pixelSize: 13
                        elide: Text.ElideRight
                        width: parent.width
                    }
                }
                Text {
                    id: playerIcon
                    anchors.right: parent.right
                    text: root._identity.toLowerCase().includes("spotify") ? "\uf1bc" : "\uf001"
                    color: Colors.fg
                    font.pixelSize: 18
                    font.family: "JetBrainsMono Nerd Font"
                }
            }

            // --- PROGRESS BAR WITH CLICK FUNCTION ---
            Rectangle {
                id: barBg
                width: parent.width
                height: 8
                radius: 4
                color: Colors.bg2

                Rectangle {
                    width: (root._length > 0) ? Math.min((root._position / root._length), 1.0) * barBg.width : 0
                    height: parent.height
                    radius: 4
                    color: Colors.fg
                }

                // Seek MouseArea
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root._length > 0) {
                            // Calculate percentage based on mouse X position
                            let percentage = mouseX / width;
                            let seekTarget = percentage * root._length;

                            // Send seek command
                            Quickshell.execDetached(["playerctl", "position", seekTarget.toString()]);

                            // Update local UI immediately for responsiveness
                            root._position = seekTarget;
                        }
                    }
                }
            }

            Item {
                width: parent.width
                height: 48
                Text {
                    text: formatTime(root._position)
                    color: Colors.fg
                    font.pixelSize: 12
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 8
                }
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 2
                    spacing: 8
                    Rectangle {
                        width: 36
                        height: 32
                        radius: 6
                        color: Colors.bg2
                        Text {
                            anchors.centerIn: parent
                            text: "\uf048"
                            color: Colors.fg
                            font.family: "JetBrainsMono Nerd Font"
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: Quickshell.execDetached(["playerctl", "previous"])
                        }
                    }
                    Rectangle {
                        width: 36
                        height: 32
                        radius: 6
                        color: Colors.bg2
                        Text {
                            anchors.centerIn: parent
                            text: root.isPlaying ? "\uf04c" : "\uf04b"
                            color: Colors.fg
                            font.family: "JetBrainsMono Nerd Font"
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: Quickshell.execDetached(["playerctl", "play-pause"])
                        }
                    }
                    Rectangle {
                        width: 36
                        height: 32
                        radius: 6
                        color: Colors.bg2
                        Text {
                            anchors.centerIn: parent
                            text: "\uf051"
                            color: Colors.fg
                            font.family: "JetBrainsMono Nerd Font"
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: Quickshell.execDetached(["playerctl", "next"])
                        }
                    }
                }
                Text {
                    text: formatTime(root._length)
                    color: Colors.fg
                    font.pixelSize: 12
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 8
                }
            }
        }
    }
}
