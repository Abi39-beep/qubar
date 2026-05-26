import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import "../.."

Item {
    anchors.fill: parent
    NotificationServer { id: server; onNotification: n => { n.tracked = true; } }

    Rectangle {
        width: 70; height: 24; radius: 4; color: Colors.red; anchors.top: parent.top; anchors.right: parent.right; z: 2
        Text { anchors.centerIn: parent; text: "󰆴 Clear"; color: Colors.bg0; font.bold: true; font.pixelSize: 11 }
        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { try { let items = server.trackedNotifications.values; for (let i = items.length - 1; i >= 0; i--) items[i].dismiss(); } catch(e) {} } }
    }

    ListView {
        id: notifList; anchors.fill: parent; anchors.topMargin: 34; clip: true; spacing: 8; model: server.trackedNotifications
        delegate: Rectangle {
            width: parent.width; implicitHeight: contentCol.implicitHeight + 24; color: Colors.bg0; border.color: (modelData && modelData.urgency === 2) ? Colors.red : Colors.blue; border.width: 1; radius: 12
            Column { id: contentCol; anchors.fill: parent; anchors.margins: 12; spacing: 4
                Text { text: (modelData && modelData.appName) ? modelData.appName : "System"; color: Colors.blue; font.pixelSize: 11; font.bold: true }
                Text { text: (modelData && modelData.summary) ? modelData.summary : ""; color: Colors.fg; font.pixelSize: 13; font.bold: true; width: parent.width; wrapMode: Text.Wrap }
                Text { text: ((modelData && modelData.body) ? modelData.body : "").replace(/<[^>]*>?/gm, ''); color: Colors.grey1; font.pixelSize: 12; width: parent.width; wrapMode: Text.Wrap; elide: Text.ElideRight; maximumLineCount: 5 }
            }
        }
    }
    Text { anchors.centerIn: parent; text: "No new notifications"; color: Colors.grey0; font.pixelSize: 12; visible: notifList.count === 0 }
}
