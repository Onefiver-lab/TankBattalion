import QtQuick
import QtQuick.Controls
import com.game.tank 1.0

Window {
    width: 800
    height: 600
    visible: true
    title: "Tank Battle - Backend Test"

    GameController {
        id: gameController
        onGameOver: {
            console.log("Game Over Signalled!");
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 20

        Button {
            text: "1. 初始化并开始游戏循环"
            onClicked: {
                gameController.startGame();
                printTimer.start();
            }
        }

        Button {
            text: "2. 发射一颗子弹 (往右飞行)"
            onClicked: {
                gameController.spawnPlayerBullet(100, 200, 3);
                console.log("Bullet spawned by Player.");
            }
        }
    }

    Timer {
        id: printTimer
        interval: 100
        repeat: true
        onTriggered: {
            var bullets = gameController.bullets;
            if (bullets.length > 0) {
                console.log("First Bullet X position: " + bullets[0].x);
            }
        }
    }
}