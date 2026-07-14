import QtQuick

Item {
    id: root
    property var bullet
    property int bulletSize: 10

    width: bulletSize
    height: bulletSize
    visible: bullet && bullet.active
    x: bullet ? bullet.x - 1 : 0
    y: bullet ? bullet.y - 1 : 0

    // Glow effect
    Rectangle {
        id: glow
        width: root.bulletSize + 6
        height: root.bulletSize + 6
        anchors.centerIn: parent
        radius: width / 2
        color: {
            if (!root.bullet) return "#ffb703";
            if (root.bullet.shooterId === 1) return "#4cc9f0";
            if (root.bullet.shooterId === 2) return "#f72585";
            return "#ffb703";
        }
        opacity: 0.25

        Behavior on opacity {
            NumberAnimation { duration: 100 }
        }
    }

    // Core bullet
    Rectangle {
        id: core
        width: root.bulletSize
        height: root.bulletSize
        anchors.centerIn: parent
        radius: width / 2
        color: {
            if (!root.bullet) return "#ffb703";
            if (root.bullet.shooterId === 1) return "#90e0ef";
            if (root.bullet.shooterId === 2) return "#f48c06";
            return "#ffb703";
        }
        border.color: {
            if (!root.bullet) return "#ffaa00";
            if (root.bullet.shooterId === 1) return "#48cae4";
            if (root.bullet.shooterId === 2) return "#d00000";
            return "#ffaa00";
        }
        border.width: 1
    }

    // Highlight
    Rectangle {
        width: 4
        height: 4
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 2
        color: "#fff"
        radius: 2
        opacity: 0.7
    }

    // Trail particles
    Repeater {
        model: 3
        Rectangle {
            width: root.bulletSize - index * 2
            height: root.bulletSize - index * 2
            anchors.centerIn: parent
            radius: width / 2
            color: core.color
            opacity: 0.3 - index * 0.08

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { to: 0.1; duration: 80 + index * 40 }
                NumberAnimation { to: 0.3 - index * 0.08; duration: 80 + index * 40 }
            }
        }
    }
}
