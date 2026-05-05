import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import "."

Rectangle {
    id: notifWidget
    width: 30; height: 30; radius: 15
    color: Colors.bg1 
    border.width: 1
    border.color: Colors.bg2

    NotificationServer {
        id: server
        onNotification: (notification) => {
            // Adds the incoming notification to your history model
            notification.tracked = true; 
        }
    }

    Text {
        anchors.centerIn: parent
        text: "󰂚"
        font.pixelSize: 15
        font.family: "JetBrainsMono Nerd Font"
        color: (notifList.count > 0) ? Colors.blue : Colors.fg 
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: notifPopup.visible = !notifPopup.visible
    }

    Component {
        id: notifDelegate
        
        Rectangle {
            id: cardRoot
            width: parent ? parent.width : 320
            
            // --- NEW LOGIC ---
            // Checks if this card is currently inside the floating OSD
            property bool isOsd: ListView.view === null
            property bool osdExpired: false
            
            // If it's the OSD and 5 seconds passed, hide it. Otherwise, always show it.
            visible: isOsd ? !osdExpired : true
            // Collapse the height when hidden so it doesn't leave an invisible gap
            implicitHeight: visible ? (contentCol.implicitHeight + 24) : 0
            
            color: Colors.bg0
            
            border.color: {
                if (modelData && modelData.urgency === 2) return Colors.red;
                return Colors.blue;
            }
            border.width: 1
            radius: 12

            Timer {
                interval: 5000
                running: cardRoot.isOsd && modelData && modelData.urgency !== 2 && !cardRoot.osdExpired
                onTriggered: {
                    // Just hide the floating OSD instead of deleting the data!
                    cardRoot.osdExpired = true;
                }
            }

            Row {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                Column {
                    id: contentCol
                    width: parent.width - 34 
                    spacing: 4

                    Row {
                        spacing: 6
                        Text { text: "󰎆"; color: Colors.blue; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font" }
                        Text { text: (modelData && modelData.appName) ? modelData.appName : "System"; color: Colors.blue; font.pixelSize: 11; font.bold: true }
                    }

                    Text {
                        text: (modelData && modelData.summary) ? modelData.summary : ""
                        color: Colors.fg; font.pixelSize: 13; font.bold: true
                        width: parent.width; wrapMode: Text.Wrap
                    }

                    Text {
                        text: ((modelData && modelData.body) ? modelData.body : "").replace(/<[^>]*>?/gm, '')
                        color: Colors.grey1; font.pixelSize: 12
                        width: parent.width; wrapMode: Text.Wrap
                        visible: text.length > 0
                    }
                }
            }

            Rectangle {
                anchors.right: parent.right; anchors.top: parent.top; anchors.margins: 12
                width: 24; height: 24; radius: 4
                color: closeMouse.containsMouse ? Colors.red : "transparent"
                Text { 
                    anchors.centerIn: parent; text: "󰅖" 
                    color: closeMouse.containsMouse ? Colors.bg0 : Colors.grey1
                    font.pixelSize: 14; font.family: "JetBrainsMono Nerd Font" 
                }
                MouseArea {
                    id: closeMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (cardRoot.isOsd) {
                            // Clicking X on the OSD hides it but keeps it in history
                            cardRoot.osdExpired = true;
                        } else {
                            // Clicking X in the popup completely deletes it
                            if (modelData) {
                                try { modelData.dismiss(); } catch(e) {}
                            }
                        }
                    }
                }
            }
        }
    }

    PopupWindow {
        id: notifPopup
        anchor.item: notifWidget
        anchor.edges: Edges.Bottom | Edges.Left
        
        implicitWidth: 300 
        implicitHeight: 380 
        
        visible: false
        color: "transparent"
        grabFocus: true 
        
        onVisibleChanged: { if (visible) bgRect.forceActiveFocus() }

        Rectangle {
            id: bgRect
            anchors.fill: parent; anchors.topMargin: 10
            color: Colors.bg0; border.color: Colors.grey0; border.width: 1; radius: 8
            focus: true
            Keys.onEscapePressed: notifPopup.visible = false
            onActiveFocusChanged: { if (!activeFocus) notifPopup.visible = false }

            Column {
                anchors.fill: parent; anchors.margins: 10; spacing: 10

                Row {
                    width: parent.width
                    Text { 
                        text: "Notifications"
                        color: Colors.fg; font.bold: true; font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Item { width: parent.width - 170; height: 1 }
                    
                    Rectangle {
                        width: 70; height: 24; radius: 4
                        color: Colors.red
                        anchors.verticalCenter: parent.verticalCenter
                        Text { 
                            anchors.centerIn: parent; text: "󰆴 Clear" 
                            color: Colors.bg0; font.bold: true; font.pixelSize: 11; font.family: "JetBrainsMono Nerd Font"
                        }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                try {
                                    let itemsToClear = server.trackedNotifications.values;
                                    for (let i = itemsToClear.length - 1; i >= 0; i--) {
                                        itemsToClear[i].dismiss();
                                    }
                                } catch(err) {}
                            }
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: Colors.bg2 } 

                Item {
                    width: parent.width; height: 310
                    ListView {
                        id: notifList
                        anchors.fill: parent; clip: true; spacing: 8
                        model: server.trackedNotifications
                        delegate: notifDelegate
                    }
                    Text {
                        anchors.centerIn: parent; text: "No new notifications"
                        color: Colors.grey0; font.pixelSize: 12
                        visible: notifList.count === 0
                    }
                }
            }
        }
    }

    PanelWindow {
        id: osdWindow
        anchors.top: true
        anchors.right: true
        
        implicitWidth: 335 
        implicitHeight: osdCol.implicitHeight > 0 ? (osdCol.implicitHeight + 60) : 1
        
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        
        visible: !notifPopup.visible

        Column {
            id: osdCol
            width: 320
            spacing: 10
            
            anchors.top: parent.top
            anchors.topMargin: 50
            anchors.right: parent.right
            anchors.rightMargin: 15

            Repeater {
                model: server.trackedNotifications
                delegate: notifDelegate
            }
        }
    }
}
