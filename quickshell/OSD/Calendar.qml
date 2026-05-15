import QtQuick
import "."

Item {
    id: calRoot
    width: parent ? parent.width : 380
    implicitHeight: calColumn.implicitHeight

    ListModel { 
        id: calendarModel 
    }
    
    function generateCalendar() {
        calendarModel.clear()
        let today = new Date()
        let currentMonth = today.getMonth()
        let currentYear = today.getFullYear()
        let currentDate = today.getDate()
        
        let firstDay = new Date(currentYear, currentMonth, 1).getDay()
        let daysInMonth = new Date(currentYear, currentMonth + 1, 0).getDate()
        
        for (let i = 0; i < 42; i++) {
            let dayNum = i - firstDay + 1
            let isCurrentMonth = dayNum > 0 && dayNum <= daysInMonth
            let isToday = isCurrentMonth && dayNum === currentDate
            
            let displayNum = ""
            if (isCurrentMonth) {
                displayNum = dayNum.toString()
            } else if (dayNum <= 0) {
                displayNum = (new Date(currentYear, currentMonth, 0).getDate() + dayNum).toString()
            } else {
                displayNum = (dayNum - daysInMonth).toString()
            }

            calendarModel.append({
                "dayText": displayNum,
                "isCurrentMonth": isCurrentMonth,
                "isToday": isToday
            })
        }
    }

    Component.onCompleted: {
        generateCalendar()
    }

    Column {
        id: calColumn
        width: parent.width
        spacing: 20

        Text {
            text: Qt.formatDateTime(new Date(), "MMMM yyyy")
            color: Colors.yellow
            font.pixelSize: 16
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 16
            Repeater {
                model:["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
                Text {
                    text: modelData
                    width: 30
                    horizontalAlignment: Text.AlignHCenter
                    color: Colors.orange
                    font.pixelSize: 14
                    font.bold: true
                }
            }
        }

        Grid {
            columns: 7
            spacing: 16
            anchors.horizontalCenter: parent.horizontalCenter
            
            Repeater {
                model: calendarModel
                Rectangle {
                    width: 30
                    height: 30
                    radius: 15
                    color: model.isToday ? Colors.yellow : "transparent"
                    Text {
                        anchors.centerIn: parent
                        text: model.dayText
                        color: model.isToday ? Colors.bg0 : (model.isCurrentMonth ? Colors.fg : Colors.bg3)
                        font.bold: model.isToday
                        font.pixelSize: 13
                    }
                }
            }
        }
    }
}
