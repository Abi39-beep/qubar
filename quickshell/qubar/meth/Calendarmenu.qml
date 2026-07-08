pragma ComponentBehavior: Bound
import QtQuick
import ".."

Item {
    id: calRoot

    height: mainCol.implicitHeight
    signal closeMenu

    property date today: new Date()
    property int viewMonth: today.getMonth()
    property int viewYear: today.getFullYear()

    focus: true

    onVisibleChanged: {
        if (visible) {
            forceActiveFocus();
            viewMonth = today.getMonth();
            viewYear = today.getFullYear();
        }
    }

    Keys.onEscapePressed: calRoot.closeMenu()

    function getDayData(index) {
        let firstDay = new Date(viewYear, viewMonth, 1).getDay();
        let daysInMonth = new Date(viewYear, viewMonth + 1, 0).getDate();
        let daysInPrevMonth = new Date(viewYear, viewMonth, 0).getDate();

        if (index < firstDay) {
            return {
                day: daysInPrevMonth - firstDay + index + 1,
                isCurrentMonth: false
            };
        } else if (index >= firstDay + daysInMonth) {
            return {
                day: index - (firstDay + daysInMonth) + 1,
                isCurrentMonth: false
            };
        } else {
            return {
                day: index - firstDay + 1,
                isCurrentMonth: true
            };
        }
    }

    function isToday(dayVal, isCurrent) {
        return isCurrent && dayVal === today.getDate() && viewMonth === today.getMonth() && viewYear === today.getFullYear();
    }

    Column {
        id: mainCol
        anchors.fill: parent
        spacing: 16

        // --- 1. MONTH TITLE & ARROWS ---
        Item {
            width: parent.width
            height: 32

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: {
                    const monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
                    return monthNames[calRoot.viewMonth] + " " + calRoot.viewYear;
                }
                color: Colors.fg0
                font.family: "SF Pro Display"
                font.pixelSize: 16
                font.bold: true
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Rectangle {
                    implicitWidth: 28
                    implicitHeight: 28
                    radius: 14
                    color: prevArea.containsMouse ? Colors.bg2 : "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: ""
                        color: Colors.fg2
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12
                    }
                    MouseArea {
                        id: prevArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            if (calRoot.viewMonth === 0) {
                                calRoot.viewMonth = 11;
                                calRoot.viewYear--;
                            } else {
                                calRoot.viewMonth--;
                            }
                        }
                    }
                }

                Rectangle {
                    implicitWidth: 28
                    implicitHeight: 28
                    radius: 14
                    color: nextArea.containsMouse ? Colors.bg2 : "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: ""
                        color: Colors.fg2
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12
                    }
                    MouseArea {
                        id: nextArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            if (calRoot.viewMonth === 11) {
                                calRoot.viewMonth = 0;
                                calRoot.viewYear++;
                            } else {
                                calRoot.viewMonth++;
                            }
                        }
                    }
                }
            }
        }

        // --- 2. THE CALENDAR WIDGET ---
        Column {
            width: parent.width
            spacing: 8

            Grid {
                id: weekGrid
                columns: 7
                width: parent.width

                property real cellWidth: width / 7

                Repeater {
                    model: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
                    Item {
                        required property string modelData

                        width: weekGrid.cellWidth
                        height: 24
                        Text {
                            anchors.centerIn: parent
                            text: parent.modelData
                            color: Colors.fg3
                            font.family: "SF Pro Display"
                            font.pixelSize: 13
                            font.bold: true
                        }
                    }
                }
            }

            // The 42-day Date Grid
            Grid {
                id: daysGrid
                columns: 7
                width: parent.width
                property real cellWidth: width / 7

                Repeater {
                    model: 42
                    Item {
                        id: dayDelegate

                        required property int index

                        width: daysGrid.cellWidth
                        height: 32

                        property var dayData: calRoot.getDayData(index)
                        property bool isTodayHighlight: calRoot.isToday(dayData.day, dayData.isCurrentMonth)

                        Rectangle {
                            anchors.centerIn: parent
                            width: Math.min(parent.width, parent.height) - 4
                            height: width
                            radius: 8
                            color: dayDelegate.isTodayHighlight ? Colors.aqua : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: dayDelegate.dayData.day
                                color: dayDelegate.isTodayHighlight ? Colors.bg0 : (dayDelegate.dayData.isCurrentMonth ? Colors.fg0 : Colors.bg3)
                                font.family: "SF Pro Display"
                                font.pixelSize: 14
                                font.bold: dayDelegate.isTodayHighlight
                            }
                        }
                    }
                }
            }
        }
    }
}
