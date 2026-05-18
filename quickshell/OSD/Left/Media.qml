import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Mpris
import ".."

Rectangle {
    id: root

    implicitWidth: 420
    implicitHeight: 130
    width: parent ? parent.width : implicitWidth
    height: implicitHeight
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
    readonly property bool _canGoNext: hasPlayer ? player.canGoNext : false
    readonly property bool _canGoPrevious: hasPlayer ? player.canGoPrevious : false
    readonly property string _artUrl: hasPlayer && player.trackArtUrl ? resolveArtUrl(player.trackArtUrl) : ""

    function resolveArtUrl(url) {
        if (!url) return ""
        var s = url.toString()
        if (s.indexOf("http://") === 0 || s.indexOf("https://") === 0 || s.indexOf("file://") === 0)
            return s
        return "file://" + s
    }

    function selectBestPlayer() {
        var list = Mpris.players.values
        var best = null
        for (var i = 0; i < list.length; i++) {
            var p = list[i]
            if (!p) continue
            if (p.playbackState === MprisPlaybackState.Playing) {
                best = p
                break
            }
            if (best === null) best = p
        }
        if (best !== root.player) {
            root.player = best
        }
    }

    Component.onCompleted: selectBestPlayer()

    Timer {
        id: playerMonitor
        interval: 2000
        running: true
        repeat: true
        onTriggered: selectBestPlayer()
    }

    Connections {
        target: root.player
        enabled: root.hasPlayer

        function onPlaybackStateChanged() {
            selectBestPlayer()
        }
    }

    Row {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 15

        Rectangle {
            width: 100
            height: 100
            radius: 10
            color: Colors.bg2
            clip: true

            Image {
                id: artImage
                anchors.fill: parent
                source: root._artUrl
                fillMode: Image.PreserveAspectCrop
                mipmap: true
                smooth: true
                asynchronous: true
                antialiasing: true
                cache: true
            }

            Text {
                anchors.centerIn: parent
                text: "\uf001"
                color: Colors.grey1
                font.pixelSize: 32
                font.family: "JetBrainsMono Nerd Font"
                visible: artImage.status !== Image.Ready || root._artUrl === ""
            }
        }

        Item {
            width: parent.width - 115
            height: 100

            Item {
                width: parent.width
                height: 40
                anchors.top: parent.top

                Column {
                    anchors.left: parent.left
                    anchors.right: playerIcon.left
                    anchors.rightMargin: 10
                    spacing: 2

                    Text {
                        text: root._title
                        color: Colors.fg
                        font.pixelSize: 16
                        font.bold: true
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        width: parent.width
                    }

                    Text {
                        text: root._artist
                        color: Colors.grey1
                        font.pixelSize: 13
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        width: parent.width
                    }
                }

                Text {
                    id: playerIcon
                    anchors.right: parent.right
                    anchors.top: parent.top
                    text: {
                        if (!root._identity) return "\uf001"
                        var id = root._identity.toLowerCase()
                        if (id.indexOf("spotify") !== -1) return "\uf1bc"
                        if (id.indexOf("firefox") !== -1 || id.indexOf("mozilla") !== -1) return "\uf269"
                        return "\uf001"
                    }
                    color: Colors.fg
                    font.pixelSize: 16
                    font.family: "JetBrainsMono Nerd Font"
                }
            }

            Item {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 10
                width: parent.width
                height: 28

                Row {
                    anchors.centerIn: parent
                    spacing: 12

                    Rectangle {
                        width: 32
                        height: 32
                        radius: 6
                        color: Colors.bg2

                        Text {
                            anchors.centerIn: parent
                            text: "\uf048"
                            color: Colors.fg
                            font.pixelSize: 14
                            font.family: "JetBrainsMono Nerd Font"
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (root.hasPlayer && root._canGoPrevious)
                                    root.player.previous()
                            }
                        }
                    }

                    Rectangle {
                        width: 32
                        height: 32
                        radius: 6
                        color: Colors.bg2

                        Text {
                            anchors.centerIn: parent
                            text: root.isPlaying ? "\uf04c" : "\uf04b"
                            color: Colors.fg
                            font.pixelSize: 14
                            font.family: "JetBrainsMono Nerd Font"
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (root.hasPlayer)
                                    root.player.togglePlaying()
                            }
                        }
                    }

                    Rectangle {
                        width: 32
                        height: 32
                        radius: 6
                        color: Colors.bg2

                        Text {
                            anchors.centerIn: parent
                            text: "\uf051"
                            color: Colors.fg
                            font.pixelSize: 14
                            font.family: "JetBrainsMono Nerd Font"
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (root.hasPlayer && root._canGoNext)
                                    root.player.next()
                            }
                        }
                    }
                }
            }
        }
    }
}
