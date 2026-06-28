import QtQuick
import Quickshell

Item {
    id: notifRoot

    property var activeNotif: null
    signal dismissed
    property real timeoutProgress: 1.0

    clip: true

    property int dynamicHeight: Math.max(Config.notifHeight, textColumn.implicitHeight + (Config.notifMargin * 2) + Config.notifBarHeight + 12)

    onActiveNotifChanged: {
        if (notifRoot.activeNotif) {
            console.log("Debug expireTimeout:", notifRoot.activeNotif.expireTimeout);
            progressAnim.stop();
            notifRoot.timeoutProgress = 1.0;
            progressAnim.start();
        } else {
            progressAnim.stop();
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onEntered: progressAnim.pause()
        onExited: progressAnim.resume()

        onClicked: {
            if (notifRoot.activeNotif) {
                if (typeof notifRoot.activeNotif.invokeDefaultAction === "function") {
                    notifRoot.activeNotif.invokeDefaultAction();
                } else {
                    notifRoot.activeNotif.dismiss();
                }
            }
            notifRoot.dismissed();
        }
    }

    Row {
        anchors.fill: parent
        anchors.margins: Config.notifMargin
        spacing: Config.notifSpacing

        Rectangle {
            width: Config.notifIconBoxSize
            height: Config.notifIconBoxSize
            radius: Config.notifIconBoxRadius
            color: Colors.bg0
            anchors.top: parent.top

            Image {
                anchors.centerIn: parent
                width: Config.notifIconBoxSize - 12
                height: Config.notifIconBoxSize - 12
                source: notifRoot.activeNotif && notifRoot.activeNotif.appIcon ? Quickshell.iconPath(notifRoot.activeNotif.appIcon) : ""
                fillMode: Image.PreserveAspectFit
                visible: notifRoot.activeNotif && notifRoot.activeNotif.appIcon && notifRoot.activeNotif.appIcon !== ""
            }

            Text {
                anchors.centerIn: parent
                text: Config.notifDefaultIcon
                font.family: Config.fontName
                font.pixelSize: Config.notifIconFontSize
                color: Colors.aqua
                visible: !(notifRoot.activeNotif && notifRoot.activeNotif.appIcon && notifRoot.activeNotif.appIcon !== "")
            }
        }

        Column {
            id: textColumn
            anchors.top: parent.top
            width: parent.width - Config.notifIconBoxSize - Config.notifSpacing
            spacing: 4

            Text {
                text: notifRoot.activeNotif && notifRoot.activeNotif.summary ? notifRoot.activeNotif.summary : "Notification"
                font.family: Config.fontName
                font.pixelSize: Config.fontSizeNotifTitle
                font.bold: true
                color: Colors.fg0
                elide: Text.ElideRight
                width: parent.width
            }

            Text {
                text: notifRoot.activeNotif && notifRoot.activeNotif.body ? notifRoot.activeNotif.body : ""
                font.family: Config.fontName
                font.pixelSize: Config.fontSizeNotifBody
                color: Colors.fg3
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
                maximumLineCount: 4
                width: parent.width
            }
        }
    }

    Rectangle {
        id: timeoutBar
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.bottomMargin: Config.notifBarBottomMargin
        anchors.leftMargin: Config.notifMargin

        width: notifRoot.width - (Config.notifMargin * 2)
        height: Config.notifBarHeight
        radius: Config.notifBarHeight / 2
        color: Colors.aqua

        transformOrigin: Item.Left
        transform: Scale {
            origin.x: 0
            xScale: notifRoot.timeoutProgress
        }
    }

    NumberAnimation {
        id: progressAnim
        target: notifRoot
        property: "timeoutProgress"
        from: 1.0
        to: 0.0

        duration: notifRoot.activeNotif && notifRoot.activeNotif.expireTimeout > 0 ? notifRoot.activeNotif.expireTimeout : Config.notifDefaultTimeout

        onFinished: {
            if (notifRoot.activeNotif)
                notifRoot.activeNotif.expire();
            notifRoot.dismissed();
        }
    }
}
