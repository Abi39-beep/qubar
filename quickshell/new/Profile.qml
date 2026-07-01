import QtQuick
import Quickshell

QuickToggle {
    active: true
    icon: "󰈈"
    title: "Power Profile"
    subtitle: "Balanced"
    activeColor: Colors.orange

    onToggleClicked: active = !active
    onExpandClicked: console.log("Will open Profile menu later!")
}
