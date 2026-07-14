import QtQuick

Item {
    id: root
    property real originX: 0
    property real originY: 0
    property color primaryColor: "#ffaa00"
    property color secondaryColor: "#ff4444"
    property int particleCount: 12
    property real particleLife: 600
    property real size: 30

    function explode() {
        for (var i = 0; i < root.particleCount; i++) {
            var angle = (Math.PI * 2 * i) / root.particleCount + (Math.random() * 0.5 - 0.25);
            var speed = 40 + Math.random() * 80;
            var particle = particleComponent.createObject(root, {
                x: root.originX,
                y: root.originY,
                angle: angle,
                speed: speed,
                life: root.particleLife + Math.random() * 200,
                size: 4 + Math.random() * 8,
                color: Math.random() > 0.5 ? root.primaryColor : root.secondaryColor
            });
        }

        flashAnim.start();
    }

    // Flash
    Rectangle {
        id: flash
        width: root.size * 2
        height: root.size * 2
        x: root.originX - width / 2
        y: root.originY - height / 2
        radius: width / 2
        color: "#fff"
        opacity: 0
        visible: opacity > 0.01
    }

    SequentialAnimation {
        id: flashAnim
        NumberAnimation { target: flash; property: "opacity"; to: 0.8; duration: 50 }
        NumberAnimation { target: flash; property: "opacity"; to: 0; duration: 150 }
    }

    Component {
        id: particleComponent
        Rectangle {
            id: particle
            property real angle: 0
            property real speed: 50
            property real life: 500
            property real size: 6

            width: size
            height: size
            radius: size / 2
            color: "#fff"
            opacity: 1

            ParallelAnimation {
                running: true
                NumberAnimation {
                    target: particle
                    property: "x"
                    to: particle.x + Math.cos(particle.angle) * particle.speed
                    duration: particle.life
                    easing.type: Easing.OutQuad
                }
                NumberAnimation {
                    target: particle
                    property: "y"
                    to: particle.y + Math.sin(particle.angle) * particle.speed
                    duration: particle.life
                    easing.type: Easing.OutQuad
                }
                NumberAnimation {
                    target: particle
                    property: "opacity"
                    to: 0
                    duration: particle.life
                }
                NumberAnimation {
                    target: particle
                    property: "scale"
                    to: 0.2
                    duration: particle.life
                }
                onFinished: particle.destroy()
            }
        }
    }
}
