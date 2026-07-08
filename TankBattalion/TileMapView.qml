import QtQuick

GridView {
    id: root
    property var mapData
    property int tileSize: 40

    model: root.mapData

    cellWidth: tileSize
    cellHeight: tileSize
    interactive: false

    delegate: Rectangle {
        width: root.tileSize
        height: root.tileSize


        color: modelData === 0 ? "#1e1e1e" : (modelData === 1 ? "#9e2a2b" : "#4a5759")
        border.color: "#121212"
        border.width: 1
        radius: modelData === 2 ? 3 : 0


        Row {
            visible: modelData === 1
            anchors.centerIn: parent
            spacing: 4
            Rectangle { width: 10; height: 38; color: "#6f1d1b" }
            Rectangle { width: 10; height: 38; color: "#6f1d1b" }
        }
    }
}
