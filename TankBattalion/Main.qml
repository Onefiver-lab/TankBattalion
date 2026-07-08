import QtQuick
import QtQuick.Controls
import TankBattalion 1.0

Window {
    width: 800
    height: 650
    minimumWidth: 400
    minimumHeight: 350
    visible: true
    color: "#121212"

    GameController {
        id: gameController
        onGameOver: (msg) => { endDialog.message = msg; endDialog.open() }
    }

    BattleField {
        id: battleField
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: controlHud.top
        gameController: gameController
    }

    ControlHud {
        id: controlHud
        anchors.bottom: parent.bottom
        gameController: gameController
        focusTarget: battleField
    }

    EndDialog {
        id: endDialog
    }
}