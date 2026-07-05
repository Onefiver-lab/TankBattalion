import QtQuick
import QtQuick.Controls
import com.game.tank 1.0

Window {
    id: rootWindow
    width: 800
    height: 600
    visible: true
    title: "经典坦克大战 (QML + C++ 实训版)"
    color: "#1a1a1a" // 暗黑背景，更有游戏质感

     GameController {
        id: gameController

        onGameOver: {
            gameOverDialog.open()
        }
    }


    Item {
        id: gameStage
        anchors.fill: parent
        focus: true

        Keys.onPressed: (event) => {
            if (event.isAutoRepeat) return;

            if (event.key === Qt.Key_W || event.key === Qt.Key_Up) {
                gameController.handlePlayerMove(GameObject.Up, true);
            } else if (event.key === Qt.Key_S || event.key === Qt.Key_Down) {
                gameController.handlePlayerMove(GameObject.Down, true);
            } else if (event.key === Qt.Key_A || event.key === Qt.Key_Left) {
                gameController.handlePlayerMove(GameObject.Left, true);
            } else if (event.key === Qt.Key_D || event.key === Qt.Key_Right) {
                gameController.handlePlayerMove(GameObject.Right, true);
            } else if (event.key === Qt.Key_Space) {
                gameController.handlePlayerFire();
            }
        }

         Keys.onReleased: (event) => {
            if (event.isAutoRepeat) return;

             if (event.key === Qt.Key_W || event.key === Qt.Key_Up ||
                event.key === Qt.Key_S || event.key === Qt.Key_Down ||
                event.key === Qt.Key_A || event.key === Qt.Key_Left ||
                event.key === Qt.Key_D || event.key === Qt.Key_Right) {

                gameController.handlePlayerMove(gameController.player.direction, false);
            }
        }


        Repeater {
            model: gameController.enemies
            delegate: Rectangle {
                x: modelData.x
                y: modelData.y
                width: 40
                height: 40
                color: "crimson"
                radius: 4

                Rectangle {
                    width: 8
                    height: 16
                    color: "darkred"
                    anchors.horizontalCenter: parent.horizontalCenter
                    transform: Rotation {
                        origin.x: 4
                        origin.y: 20
                        angle: modelData.direction * 90
                    }
                }
            }
        }

        Repeater {
            model: gameController.bullets
            delegate: Rectangle {
                x: modelData.x
                y: modelData.y
                width: 8
                height: 8
                radius: 4
                color: modelData.isFromPlayer ? "cyan" : "orange"
            }
        }

        Rectangle {
            id: playerSprite
            visible: gameController.player && gameController.player.active
            x: gameController.player ? gameController.player.x : 0
            y: gameController.player ? gameController.player.y : 0
            width: 40
            height: 40
            color: "limegreen"
            radius: 4

            Rectangle {
                width: 8
                height: 18
                color: "forestgreen"
                anchors.horizontalCenter: parent.horizontalCenter
                transform: Rotation {
                    origin.x: 4
                    origin.y: 20
                    angle: gameController.player ? gameController.player.direction * 90 : 0
                }
            }

            Row {
                anchors.bottom: parent.top
                anchors.bottomMargin: 4
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 2

                Repeater {
                    model: gameController.player ? gameController.player.hp : 0
                    Rectangle { width: 8; height: 4; color: "lime" }
                }
            }
        }
    }

    Row {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 20
        anchors.topMargin: 10

        Button {
            text: "开始游戏"
            onClicked: {
                gameController.startGame()
                gameStage.focus = true
            }
        }
        Button {
            text: "暂停"
            onClicked: gameController.pauseGame()
        }
    }

    Dialog {
        id: gameOverDialog
        title: "GAME OVER"
        anchors.centerIn: parent
        standardButtons: Dialog.Ok
        modal: true

        Label {
            text: "你的战车被无情摧毁了！"
            font.pixelSize: 18
        }
        onAccepted: {
            gameOverDialog.close()
        }
    }
}