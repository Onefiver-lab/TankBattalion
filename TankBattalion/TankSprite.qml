import QtQuick

Rectangle {
    id: root
    property var tank
    property string label
    property color bodyColor
    property color cannonColor
    property color textColor: "#fff"
    property int tankSize: 40

    width: tankSize
    height: tankSize
    color: bodyColor
    radius: 4
    visible: tank && tank.active
    x: tank ? tank.x : 0
    y: tank ? tank.y : 0

    Rectangle {
        width: parent.width
        height: 5
        color: "#444"
        y: -8
        radius: 2

        Rectangle {
            width: parent.width * (root.tank ? root.tank.hp / root.tank.maxHp : 0)
            height: parent.height
            color: "#00ff66"
            radius: 2
        }
    }

    Rectangle {
        width: 8
        height: 18
        color: root.cannonColor
        anchors.horizontalCenter: parent.horizontalCenter
        transform: Rotation {
            origin.x: 4
            origin.y: 20
            angle: root.tank ? root.tank.direction * 90 : 0
        }
    }

    Text {
        text: root.label + ":" + (root.tank && root.tank.ammo === -1 ? "\u221e" : (root.tank ? root.tank.ammo : 0))
        color: root.textColor
        font.pixelSize: 10
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
