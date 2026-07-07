import QtQuick
import QtQuick.Controls
import com.game.tank 1.0

Window {
    id: rootWindow
    width: 800
    height: 650
    visible: true
    title: "经典坦克大战：战场掌控版"
    color: "#121212"

    GameController {
        id: gameController
        onGameOver: (msg) => {
            endDialogText.text = msg
            endDialog.open()
        }
    }

    Item {
        id: battleField
        width: 800
        height: 600
        focus: true

        Keys.onPressed: (event) => {
            if (event.isAutoRepeat) return;
            if (event.key === Qt.Key_W) gameController.handlePlayerMove(1, GameObject.Up, true)
            else if (event.key === Qt.Key_S) gameController.handlePlayerMove(1, GameObject.Down, true)
            else if (event.key === Qt.Key_A) gameController.handlePlayerMove(1, GameObject.Left, true)
            else if (event.key === Qt.Key_D) gameController.handlePlayerMove(1, GameObject.Right, true)
            else if (event.key === Qt.Key_Space) gameController.handlePlayerFire(1)

            else if (event.key === Qt.Key_Up) gameController.handlePlayerMove(2, GameObject.Up, true)
            else if (event.key === Qt.Key_Down) gameController.handlePlayerMove(2, GameObject.Down, true)
            else if (event.key === Qt.Key_Left) gameController.handlePlayerMove(2, GameObject.Left, true)
            else if (event.key === Qt.Key_Right) gameController.handlePlayerMove(2, GameObject.Right, true)
            else if (event.key === Qt.Key_Slash) gameController.handlePlayerFire(2)
        }

        Keys.onReleased: (event) => {
            if (event.isAutoRepeat) return;
            if (event.key === Qt.Key_W || event.key === Qt.Key_S || event.key === Qt.Key_A || event.key === Qt.Key_D) {
                if(gameController.player1) gameController.handlePlayerMove(1, gameController.player1.direction, false)
            }
            if (event.key === Qt.Key_Up || event.key === Qt.Key_Down || event.key === Qt.Key_Left || event.key === Qt.Key_Right) {
                if(gameController.player2) gameController.handlePlayerMove(2, gameController.player2.direction, false)
            }
        }

        GridView {
            anchors.fill: parent
            cellWidth: 40; cellHeight: 40
            interactive: false
            model: gameController.mapManager.mapData
            delegate: Rectangle {
                width: 40; height: 40
                color: modelData === 0 ? "#1e1e1e" : (modelData === 1 ? "#9e2a2b" : "#4a5759")
                border.color: "#121212"
                border.width: 1
                radius: modelData === 2 ? 3 : 0

                Row {
                    visible: modelData === 1
                    anchors.centerIn: parent
                    spacing: 4
                    Rectangle { width: 10; height: 38; color: "#6f1d1b" }
                    Rectangle { width: 10; height: 38; color: "#6f1d1b" }
                }
            }
        }

        Repeater {
            model: gameController.enemies
            delegate: Rectangle {
                x: modelData.x; y: modelData.y; width: 40; height: 40; color: "#e63946"; radius: 5
                Rectangle {
                    width: 8; height: 16; color: "#000"; anchors.horizontalCenter: parent.horizontalCenter
                    transform: Rotation { origin.x: 4; origin.y: 20; angle: modelData.direction * 90 }
                }
            }
        }

        Repeater {
            model: gameController.bullets
            delegate: Rectangle {
                x: modelData.x; y: modelData.y; width: 8; height: 8; radius: 4
                color: modelData.shooterId === 1 ? "#4cc9f0" : (modelData.shooterId === 2 ? "#f72585" : "#ffb703")
            }
        }

        Rectangle {
            id: p1Sprite
            visible: gameController.player1 && gameController.player1.active
            x: gameController.player1 ? gameController.player1.x : 0
            y: gameController.player1 ? gameController.player1.y : 0
            width: 40; height: 40; color: "#2a9d8f"; radius: 4

            Rectangle {
                width: parent.width; height: 5; color: "#444"
                y: -8; radius: 2
                Rectangle {
                    width: parent.width * (gameController.player1 ? gameController.player1.hp / gameController.player1.maxHp : 0)
                    height: parent.height; color: "#00ff66"; radius: 2
                }
            }

            Rectangle {
                width: 8; height: 18; color: "#1d3557"; anchors.horizontalCenter: parent.horizontalCenter
                transform: Rotation { origin.x: 4; origin.y: 20; angle: gameController.player1 ? gameController.player1.direction * 90 : 0 }
            }
            Text { text: "P1:" + (gameController.player1 && gameController.player1.ammo === -1 ? "∞" : (gameController.player1 ? gameController.player1.ammo : 0)); color: "#fff"; font.pixelSize: 10; anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter }
        }

        Rectangle {
            id: p2Sprite
            visible: gameController.player2 && gameController.player2.active
            x: gameController.player2 ? gameController.player2.x : 0
            y: gameController.player2 ? gameController.player2.y : 0
            width: 40; height: 40; color: "#a2d2ff"; radius: 4

            Rectangle {
                width: parent.width; height: 5; color: "#444"
                y: -8; radius: 2
                Rectangle {
                    width: parent.width * (gameController.player2 ? gameController.player2.hp / gameController.player2.maxHp : 0)
                    height: parent.height; color: "#00ff66"; radius: 2
                }
            }

            Rectangle {
                width: 8; height: 18; color: "#7209b7"; anchors.horizontalCenter: parent.horizontalCenter
                transform: Rotation { origin.x: 4; origin.y: 20; angle: gameController.player2 ? gameController.player2.direction * 90 : 0 }
            }
            Text { text: "P2:" + (gameController.player2 && gameController.player2.ammo === -1 ? "∞" : (gameController.player2 ? gameController.player2.ammo : 0)); color: "#000"; font.pixelSize: 10; anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter }
        }
    }

    Rectangle {
        id: controlHud
        width: 800; height: 50
        anchors.bottom: parent.bottom
        color: "#222"

        Row {
            anchors.centerIn: parent
            spacing: 12

            ComboBox {
                id: modeBox
                model: ["单人模式", "双人同屏", "PVP对战"]
                currentIndex: gameController.gameMode
                onCurrentIndexChanged: gameController.gameMode = currentIndex
            }

            ComboBox {
                id: diffBox
                model: ["简单 (3敌人/无限弹)", "中等 (6敌人/无限弹)", "困难 (12敌人/100弹)", "地狱 (20敌人/50弹)"]
                visible: modeBox.currentIndex !== 2
                currentIndex: gameController.difficulty
                onCurrentIndexChanged: gameController.difficulty = currentIndex
            }

            Button {
                text: "重整战局并启动"
                onClicked: {
                    gameController.startGame()
                    battleField.focus = true
                }
            }
        }
    }

    Dialog {
        id: endDialog
        title: "战况结算"
        anchors.centerIn: parent
        modal: true
        standardButtons: Dialog.Ok
        Label { id: endDialogText; font.pixelSize: 16 }
    }
}