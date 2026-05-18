pragma Singleton
import QtQuick

QtObject {
    id: root

    // Floating/Layout properties
    property int barWidth: 0
    property int barHeight: 38
    property int barRadius: 0
    property real barOpacity: 1.0
    property int marginTop: 0
    property int marginSides: 0
    property int barMargin: 5
    property int widgetSpacing: 8
    property int widgetRadius: 15

    // Global widget properties
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 15
    property int workspaceCount: 5
    property string timeFormat: "hh:mm AP"
    property string dateFormat: "ddd, MMM d"

    Component.onCompleted: {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", Qt.resolvedUrl("settings.json"), false);
        xhr.send();
        
        if (xhr.status === 200 || xhr.status === 0) {
            try {
                var data = JSON.parse(xhr.responseText);
                if (data.layout) {
                    if (data.layout.bar_width !== undefined) root.barWidth = data.layout.bar_width;
                    if (data.layout.bar_height) root.barHeight = data.layout.bar_height;
                    if (data.layout.bar_radius !== undefined) root.barRadius = data.layout.bar_radius;
                    if (data.layout.bar_opacity !== undefined) root.barOpacity = data.layout.bar_opacity;
                    if (data.layout.margin_top !== undefined) root.marginTop = data.layout.margin_top;
                    if (data.layout.margin_sides !== undefined) root.marginSides = data.layout.margin_sides;
                    if (data.layout.bar_margin) root.barMargin = data.layout.bar_margin;
                    if (data.layout.widget_spacing) root.widgetSpacing = data.layout.widget_spacing;
                    if (data.layout.widget_radius) root.widgetRadius = data.layout.widget_radius;
                }
                if (data.font) {
                    if (data.font.family) root.fontFamily = data.font.family;
                    if (data.font.size) root.fontSize = data.font.size;
                }
                if (data.workspaces && data.workspaces.count) root.workspaceCount = data.workspaces.count;
                if (data.clock) {
                    if (data.clock.time_format) root.timeFormat = data.clock.time_format;
                    if (data.clock.date_format) root.dateFormat = data.clock.date_format;
                }
            } catch(e) { console.log("Could not load settings.json"); }
        }
    }
}
