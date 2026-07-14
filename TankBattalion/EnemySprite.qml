import QtQuick

Item {
    id: root
    property var enemy
    property int tankSize: 40

    width: tankSize
    height: tankSize
    visible: enemy && enemy.active
    x: enemy ? enemy.x : 0
    y: enemy ? enemy.y : 0

    // Shadow
    Rectangle {
        width: root.tankSize + 4
        height: root.tankSize + 4
        x: 2
        y: 4
        radius: 6
        color: "#000"
        opacity: 0.35
    }

    // Enemy body
    Rectangle {
        id: body
        width: root.tankSize
        height: root.tankSize
        color: "#c0392b"
        radius: 5
        border.color: "#8b1e1e"
        border.width: 1

        // Inner panel
        Rectangle {
            anchors.fill: parent
            anchors.margins: 3
            color: "#d65050"
            radius: 3
            opacity: 0.4
        }

        // Diagonal warning stripes
        Canvas {
            anchors.fill: parent
            anchors.margins: 4
            opacity: 0.15
            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                ctx.fillStyle = "#000";
                for (var i = -height; i < width; i += 12) {
                    ctx.beginPath();
                    ctx.moveTo(i, 0);
                    ctx.lineTo(i + 8, 0);
                    ctx.lineTo(i + 8 + height, height);
                    ctx.lineTo(i + height, height);
                    ctx.closePath();
                    ctx.fill();
                }
            }
        }

        // Tracks
        Rectangle {
            width: 6
            height: parent.height - 4
            anchors.left: parent.left
            anchors.leftMargin: 2
            anchors.verticalCenter: parent.verticalCenter
            color: "#5c1515"
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
                        color: "#3d0e0e"
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
            color: "#5c1515"
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
                        color: "#3d0e0e"
                    }
                }
            }
        }

        // Turret base
        Rectangle {
            width: 16
            height: 16
            anchors.centerIn: parent
            color: "#8b1e1e"
            radius: 8
            border.color: "#5c1515"
            border.width: 1

            // Enemy eye glow
            Rectangle {
                width: 8
                height: 8
                anchors.centerIn: parent
                color: "#ff4444"
                radius: 4

                Rectangle {
                    width: 4
                    height: 4
                    anchors.centerIn: parent
                    color: "#ff8888"
                    radius: 2
                }
            }
        }
    }

    // Cannon
    Rectangle {
        width: 7
        height: 18
        color: "#2c2c2c"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -9
        radius: 2
        border.color: "#1a1a1a"
        border.width: 1

        transform: Rotation {
            origin.x: 3.5
            origin.y: 16
            angle: root.enemy ? root.enemy.direction * 90 : 0
        }
    }

    // Enemy identifier text
    Text {
        text: "E"
        color: "#ff6666"
        font.pixelSize: 9
        font.bold: true
        anchors.top: parent.bottom
        anchors.topMargin: 2
        anchors.horizontalCenter: parent.horizontalCenter
        style: Text.Outline
        styleColor: "#000"
    }
}
