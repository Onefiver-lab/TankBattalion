import QtQuick

Item {
    id: root
    property var tank
    property string label
    property color bodyColor
    property color cannonColor
    property color textColor: "#fff"
    property int tankSize: 40

    width: tankSize
    height: tankSize
    visible: tank && tank.active
    x: tank ? tank.x : 0
    y: tank ? tank.y : 0

    // Shadow
    Rectangle {
        id: shadow
        width: root.tankSize + 4
        height: root.tankSize + 4
        x: 2
        y: 4
        radius: 6
        color: "#000"
        opacity: 0.35
    }

    // Tank body
    Rectangle {
        id: body
        width: root.tankSize
        height: root.tankSize
        color: root.bodyColor
        radius: 5
        border.color: Qt.darker(root.bodyColor, 1.4)
        border.width: 1

        // Inner highlight
        Rectangle {
            anchors.fill: parent
            anchors.margins: 3
            color: Qt.lighter(root.bodyColor, 1.15)
            radius: 3
            opacity: 0.5
        }

        // Tracks (left & right)
        Rectangle {
            width: 6
            height: parent.height - 4
            anchors.left: parent.left
            anchors.leftMargin: 2
            anchors.verticalCenter: parent.verticalCenter
            color: Qt.darker(root.bodyColor, 1.8)
            radius: 2

            // Track tread detail
            Column {
                anchors.fill: parent
                anchors.margins: 1
                spacing: 3
                Repeater {
                    model: 5
                    Rectangle {
                        width: parent.width
                        height: 2
                        color: Qt.darker(root.bodyColor, 2.2)
                    }
                }
            }
        }

        Rectangle {
            width: 6
            height: parent.height - 4
            anchors.right: parent.right
            anchors.rightMargin: 2
            anchors.verticalCenter: parent.verticalCenter
            color: Qt.darker(root.bodyColor, 1.8)
            radius: 2

            Column {
                anchors.fill: parent
                anchors.margins: 1
                spacing: 3
                Repeater {
                    model: 5
                    Rectangle {
                        width: parent.width
                        height: 2
                        color: Qt.darker(root.bodyColor, 2.2)
                    }
                }
            }
        }

        // Central turret base
        Rectangle {
            width: 18
            height: 18
            anchors.centerIn: parent
            color: Qt.darker(root.bodyColor, 1.2)
            radius: 9
            border.color: Qt.darker(root.bodyColor, 1.5)
            border.width: 1
        }
    }

    // Cannon
    Rectangle {
        id: cannon
        width: 8
        height: 20
        color: root.cannonColor
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -10
        radius: 2
        border.color: Qt.darker(root.cannonColor, 1.4)
        border.width: 1

        transform: Rotation {
            origin.x: 4
            origin.y: 18
            angle: root.tank ? root.tank.direction * 90 : 0
        }

        // Cannon muzzle highlight
        Rectangle {
            width: 4
            height: 6
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            color: Qt.lighter(root.cannonColor, 1.3)
            radius: 1
        }
    }

    // Health bar
    Item {
        width: root.tankSize + 8
        height: 6
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.top
        anchors.bottomMargin: 6

        Rectangle {
            anchors.fill: parent
            color: "#111"
            radius: 3
            border.color: "#333"
            border.width: 1
        }

        Rectangle {
            width: parent.width * (root.tank ? root.tank.hp / root.tank.maxHp : 0)
            height: parent.height
            color: root.tank && root.tank.hp > 1 ? "#00cc66" : "#ff4444"
            radius: 3

            Behavior on width {
                NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
            }
        }
    }

    // Label + Ammo
    Text {
        text: root.tank ? (root.label + (root.tank.ammo === -1 ? "" : ":" + root.tank.ammo)) : root.label
        color: root.textColor
        font.pixelSize: 10
        font.bold: true
        anchors.top: parent.bottom
        anchors.topMargin: 2
        anchors.horizontalCenter: parent.horizontalCenter
        style: Text.Outline
        styleColor: "#000"
    }

    // Hit flash effect
    Rectangle {
        anchors.fill: body
        color: "#fff"
        radius: 5
        opacity: 0

        SequentialAnimation on opacity {
            id: hitAnim
            running: false
            NumberAnimation { to: 0.6; duration: 50 }
            NumberAnimation { to: 0; duration: 100 }
        }
    }
}
