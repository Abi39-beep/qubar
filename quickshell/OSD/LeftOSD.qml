import QtQuick
import Quickshell
import Quickshell.Wayland
import "."

Item {
    id: leftRoot

    function toggleLeft() {
        leftOSDWindow.visible = !leftOSDWindow.visible
    }

    PanelWindow {
        id: leftOSDWindow
        visible: false 
        
        exclusionMode: ExclusionMode.Ignore 
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.namespace: "leftosd"
        
        anchors { 
            top: true
            bottom: true
            left: true
            right: true
        }
        
        color: "transparent"

        MouseArea {
            anchors.fill: parent
            onClicked: {
                leftOSDWindow.visible = false
            }
        }

        Rectangle {
            id: leftBg
            width: 420
            anchors { 
                left: parent.left
                top: parent.top
                bottom: parent.bottom 
            }
            anchors.margins: 20
            
            color: Qt.alpha(Colors.bg0, 0.50)
            border.color: Colors.bg2
            border.width: 2
            radius: 15
            
            MouseArea { 
                anchors.fill: parent 
            }

            focus: true
            Keys.onEscapePressed: {
                leftOSDWindow.visible = false
            }
            onVisibleChanged: { 
                if (visible) {
                    leftBg.forceActiveFocus()
                }
            }

            Column {
                anchors.fill: parent
                anchors.margins: 25
                spacing: 25

                Clock {}

                Rectangle { 
                    width: parent.width
                    height: 1
                    color: Colors.bg2 
                }

                Calendar {}

                Rectangle { 
                    width: parent.width
                    height: 1
                    color: Colors.bg2 
                }

                Media {}

                Rectangle { 
                    width: parent.width
                    height: 1
                    color: Colors.bg2 
                }

                Volume {}
            }
        }
    }
}
