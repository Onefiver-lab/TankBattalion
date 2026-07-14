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

        color: modelData === 0 ? "#1a1a1a" : "transparent"
        border.color: modelData === 0 ? "#222" : "transparent"
        border.width: 1

        // Ground texture detail
        Rectangle {
            visible: modelData === 0
            anchors.fill: parent
            color: "transparent"

            Rectangle {
                x: 8; y: 8; width: 4; height: 4; color: "#252525"; radius: 1
            }
            Rectangle {
                x: 28; y: 22; width: 3; height: 3; color: "#252525"; radius: 1
            }
        }

        // Brick wall (destructible)
        Rectangle {
            visible: modelData === 1
            anchors.fill: parent
            color: "#7f2a2a"
            border.color: "#5c1e1e"
            border.width: 1

            Column {
                anchors.fill: parent
                anchors.margins: 2
                spacing: 2

                Repeater {
                    model: 3
                    Row {
                        spacing: 2
                        width: parent.width
                        Repeater {
                            model: 2
                            Rectangle {
                                width: (parent.width - 2) / 2
                                height: 10
                                color: index % 2 === 0 ? "#9e3a3a" : "#8b3030"
                                border.color: "#5c1e1e"
                                border.width: 1
                                radius: 1

                                Rectangle {
                                    width: parent.width - 4
                                    height: 2
                                    anchors.top: parent.top
                                    anchors.left: parent.left
                                    anchors.margins: 1
                                    color: "#b85c5c"
                                    opacity: 0.6
                                }
                            }
                        }
                    }
                }
            }
        }

        // Steel wall (indestructible)
        Rectangle {
            visible: modelData === 2
            anchors.fill: parent
            color: "#3a4a4f"
            border.color: "#2a363a"
            border.width: 2
            radius: 3

            Rectangle {
                anchors.fill: parent
                anchors.margins: 4
                color: "#4a5a5f"
                border.color: "#5a6a6f"
                border.width: 1
                radius: 2

                Rectangle {
                    width: parent.width - 8
                    height: 3
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.margins: 2
                    color: "#6a7a7f"
                    opacity: 0.5
                }

                Rectangle {
                    width: 3
                    height: parent.height - 8
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    anchors.margins: 2
                    color: "#2a363a"
                    opacity: 0.6
                }
            }
        }
    }
}
