import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Item {
    id: notifRoot

    property var activeNotif: null
    signal dismissed

    property real timeoutProgress: 1.0

    // --- THE MAGIC HEIGHT CALCULATOR ---
    // Takes the height of your text, adds the top/bottom margins + the blue bar height + extra padding.
    // Math.max() ensures it never shrinks smaller than your Config.notifHeight!
    property int dynamicHeight: Math.max(Config.notifHeight, textColumn.implicitHeight + (Config.notifMargin * 2) + Config.notifBarHeight + 12)

    onActiveNotifChanged: {
        if (activeNotif) {
            timeoutProgress = 1.0;
            progressAnim.restart();
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
            if (activeNotif)
                activeNotif.dismiss();
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
            anchors.verticalCenter: parent.verticalCenter

            Text {
                anchors.centerIn: parent
                text: Config.notifDefaultIcon
                font.family: Config.fontName
                font.pixelSize: Config.notifIconFontSize
                color: Colors.aqua
            }
        }

        Column {
            id: textColumn // Added an ID so the root can measure how tall this text is!
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - Config.notifIconBoxSize - Config.notifSpacing
            spacing: 4

            Text {
                text: activeNotif ? activeNotif.summary : "Notification"
                font.family: Config.fontName
                font.pixelSize: Config.fontSizeNotifTitle
                font.bold: true
                color: Colors.fg0
                elide: Text.ElideRight
                width: parent.width
            }

            Text {
                text: activeNotif ? activeNotif.body : ""
                font.family: Config.fontName
                font.pixelSize: Config.fontSizeNotifBody
                color: Colors.fg3

                wrapMode: Text.WordWrap
                // REMOVED maximumLineCount! It will now wrap and push the height down infinitely!
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

        width: Math.max(0, (notifRoot.width - (Config.notifMargin * 2)) * notifRoot.timeoutProgress)
        height: Config.notifBarHeight
        radius: Config.notifBarHeight / 2
        color: Colors.aqua
    }

    NumberAnimation {
        id: progressAnim
        target: notifRoot
        property: "timeoutProgress"
        from: 1.0
        to: 0.0

        duration: activeNotif && activeNotif.expireTimeout > 0 ? (activeNotif.expireTimeout * 1000) : Config.notifDefaultTimeout

        onFinished: {
            if (activeNotif)
                activeNotif.expire();
            notifRoot.dismissed();
        }
    }
}
