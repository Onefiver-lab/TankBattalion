import QtQuick

Rectangle {
    id: root
    property var bullet
    property int bulletSize: 8

    width: bulletSize
    height: bulletSize
    radius: 4
    x: bullet ? bullet.x : 0
    y: bullet ? bullet.y : 0
    color: !bullet ? "#ffb703" : (bullet.shooterId === 1 ? "#4cc9f0" : (bullet.shooterId === 2 ? "#f72585" : "#ffb703"))
}
