import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import "."

Item {
    id: notifRoot
    anchors.fill: parent

    NotificationServer {
        id: server
        onNotification: (notification) => { 
            notification.tracked = true 
        }
    }

    Component {
        id: notifDelegate
        
        Rectangle {
            id: cardRoot
            width: ListView.view ? ListView.view.width : 320
            
            property bool isOsd: ListView.view === floatingNotifsList
            property bool osdExpired: false
            
            visible: isOsd ? !osdExpired : true
            implicitHeight: visible ? (contentCol.implicitHeight + 24) : 0
            
            color: Colors.bg1
            border.color: (modelData && modelData.urgency === 2) ? Colors.red : Colors.bg2
            border.width: 1
            radius: 10
            clip: true

            Timer {
                interval: 5000
                running: cardRoot.isOsd && modelData && modelData.urgency !== 2 && !cardRoot.osdExpired
                onTriggered: {
                    cardRoot.osdExpired = true
                }
            }

            Rectangle {
                id: timeoutBar
                height: 3
                width: cardRoot.isOsd ? parent.width : 0
                color: (modelData && modelData.urgency === 2) ? Colors.red : Colors.aqua
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                opacity: cardRoot.isOsd ? 1 : 0
                
                PropertyAnimation on width { 
                    from: cardRoot.width
                    to: 0
                    duration: 5000
                    running: cardRoot.isOsd && modelData && modelData.urgency !== 2 
                }
            }

            Row {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                Column {
                    id: contentCol
                    width: parent.width - 34 
                    spacing: 4

                    Text { 
                        text: (modelData && modelData.appName) ? modelData.appName : "System"
                        color: Colors.aqua
                        font.pixelSize: 12
                        font.bold: true 
                    }

                    Text {
                        text: (modelData && modelData.summary) ? modelData.summary : ""
                        color: Colors.fg
                        font.pixelSize: 12
                        width: parent.width
                        elide: Text.ElideRight
                    }

                    Text {
                        text: ((modelData && modelData.body) ? modelData.body : "").replace(/<[^>]*>?/gm, '')
                        color: Colors.grey1
                        font.pixelSize: 11
                        width: parent.width
                        wrapMode: Text.Wrap
                        visible: text.length > 0 && cardRoot.isOsd
                        maximumLineCount: 3
                        elide: Text.ElideRight
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (cardRoot.isOsd) {
                        cardRoot.osdExpired = true
                    } else {
                        if (modelData) {
                            try { 
                                modelData.dismiss() 
                            } catch(e) {}
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        width: 80
        height: 28
        radius: 6
        color: Colors.red
        anchors.top: parent.top
        anchors.right: parent.right
        z: 2
        
        Row { 
            anchors.centerIn: parent
            spacing: 6
            Text { 
                text: "󰆴"
                color: Colors.bg0
                font.pixelSize: 12
                font.family: "JetBrainsMono Nerd Font" 
                anchors.verticalCenter: parent.verticalCenter // FIX: Perfect Alignment
            }
            Text { 
                text: "Clear"
                color: Colors.bg0
                font.bold: true
                font.pixelSize: 12 
                anchors.verticalCenter: parent.verticalCenter // FIX: Perfect Alignment
            } 
        }
        
        MouseArea { 
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: { 
                try { 
                    let items = server.trackedNotifications.values
                    for (let i = items.length - 1; i >= 0; i--) {
                        items[i].dismiss()
                    } 
                } catch(err) {} 
            } 
        }
    }

    ListView {
        id: list
        anchors.fill: parent
        anchors.topMargin: 40
        clip: true
        spacing: 8
        model: server.trackedNotifications
        delegate: notifDelegate
    }
    
    Text { 
        anchors.centerIn: parent
        text: "No new notifications"
        color: Colors.grey1
        font.pixelSize: 12
        visible: server.trackedNotifications.count === 0 
    }

    PanelWindow {
        id: floatingNotifsWindow
        anchors.top: true
        anchors.right: true
        
        implicitWidth: 335 
        implicitHeight: osdCol.implicitHeight > 0 ? (osdCol.implicitHeight + 60) : 1
        
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        
        visible: !notifRoot.visible

        Column {
            id: osdCol
            width: 320
            spacing: 10
            
            anchors.top: parent.top
            anchors.topMargin: 50
            anchors.right: parent.right
            anchors.rightMargin: 15

            ListView {
                id: floatingNotifsList
                width: parent.width
                height: contentHeight
                spacing: 10
                interactive: false
                model: server.trackedNotifications
                delegate: notifDelegate
            }
        }
    }
}
