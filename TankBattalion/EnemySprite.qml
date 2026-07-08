import QtQuick

Rectangle {
    id: root
    property var enemy
    property int tankSize: 40

    width: tankSize
    height: tankSize
    color: "#e63946"
    radius: 5
    x: enemy ? enemy.x : 0
    y: enemy ? enemy.y : 0

    Rectangle {
        width: 8
        height: 16
        color: "#000"
        anchors.horizontalCenter: parent.horizontalCenter
        transform: Rotation {
            origin.x: 4
            origin.y: 20
            angle: root.enemy ? root.enemy.direction * 90 : 0
        }
    }
}
