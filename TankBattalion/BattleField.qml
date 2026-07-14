import QtQuick
import QtQuick.Controls
import TankBattalion 1.0

Item {
    id: root
    property var gameController
    focus: true

    anchors.fill: parent
    clip: true

    MouseArea {
        anchors.fill: parent
        onClicked: root.focus = true
    }

    Item {
        id: field
        width: 800
        height: 600
        anchors.centerIn: parent
        transformOrigin: Item.Center
        scale: Math.min(root.width / 800, (root.height - 60) / 600)

        TileMapView { anchors.fill: parent; mapData: root.gameController.mapManager.mapData }

        Repeater {
            model: root.gameController.enemies
            delegate: EnemySprite { enemy: modelData }
        }
        Repeater {
            model: root.gameController.bullets
            delegate: BulletSprite { bullet: modelData }
        }

        TankSprite {
            tank: root.gameController.player1; label: "P1"
            bodyColor: "#2a9d8f"; cannonColor: "#1d3557"; textColor: "#fff"
        }
        TankSprite {
            tank: root.gameController.player2; label: "P2"
            bodyColor: "#a2d2ff"; cannonColor: "#7209b7"; textColor: "#000"
        }

        // Particle system container
        Item {
            id: particleContainer
            anchors.fill: parent
        }
    }

    Connections {
        target: root.gameController
        function onExplosionRequested(x, y, isBig) {
            var effect = Qt.createQmlObject(
                'import QtQuick; ParticleEffect { }',
                particleContainer,
                'dynamicParticle'
            );
            effect.originX = x;
            effect.originY = y;
            effect.primaryColor = isBig ? "#ff6600" : "#ffcc00";
            effect.secondaryColor = isBig ? "#ff0000" : "#ff8800";
            effect.particleCount = isBig ? 16 : 8;
            effect.particleLife = isBig ? 700 : 400;
            effect.size = isBig ? 50 : 25;
            effect.explode();

            // Auto-cleanup after animation completes
            var cleanupTimer = Qt.createQmlObject(
                'import QtQuick; Timer { }',
                effect,
                'dynamicTimer'
            );
            cleanupTimer.interval = effect.particleLife + 100;
            cleanupTimer.repeat = false;
            cleanupTimer.triggered.connect(function() {
                effect.destroy();
            });
            cleanupTimer.start();
        }
    }

    function pressKey(event) {
        if (event.key === Qt.Key_Escape) {
            if (root.gameController.paused) root.gameController.resumeGame()
            else root.gameController.pauseGame()
            event.accepted = true
            return
        }
        if (root.gameController.paused) { event.accepted = true; return }

        if (event.key === Qt.Key_W) gameController.handlePlayerMove(1, 0, true)
        else if (event.key === Qt.Key_S) gameController.handlePlayerMove(1, 1, true)
        else if (event.key === Qt.Key_A) gameController.handlePlayerMove(1, 2, true)
        else if (event.key === Qt.Key_D) gameController.handlePlayerMove(1, 3, true)
        else if (event.key === Qt.Key_Space) gameController.handlePlayerFire(1)

        else if (event.key === Qt.Key_Up) gameController.handlePlayerMove(2, 0, true)
        else if (event.key === Qt.Key_Down) gameController.handlePlayerMove(2, 1, true)
        else if (event.key === Qt.Key_Left) gameController.handlePlayerMove(2, 2, true)
        else if (event.key === Qt.Key_Right) gameController.handlePlayerMove(2, 3, true)
        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Slash) {
            gameController.handlePlayerFire(2)
        }
    }

    function releaseKey(event) {
        if (event.key === Qt.Key_W) gameController.handlePlayerMove(1, 0, false)
        else if (event.key === Qt.Key_S) gameController.handlePlayerMove(1, 1, false)
        else if (event.key === Qt.Key_A) gameController.handlePlayerMove(1, 2, false)
        else if (event.key === Qt.Key_D) gameController.handlePlayerMove(1, 3, false)
        else if (event.key === Qt.Key_Up) gameController.handlePlayerMove(2, 0, false)
        else if (event.key === Qt.Key_Down) gameController.handlePlayerMove(2, 1, false)
        else if (event.key === Qt.Key_Left) gameController.handlePlayerMove(2, 2, false)
        else if (event.key === Qt.Key_Right) gameController.handlePlayerMove(2, 3, false)
    }

    Keys.onPressed: (event) => pressKey(event)
    Keys.onReleased: (event) => releaseKey(event)
}
