import QtQuick
import QtQuick.Controls
import QtQuick.Window
import TankBattalion 1.0

Window {
    id: root
    width: 800
    height: 650
    minimumWidth: 400
    minimumHeight: 400
    visible: true
    color: "#121212"
    title: "坦克大战"

    SettingsManager {
        id: settingsManager
        onFullscreenChanged: root.applyFullscreen()
    }
    SaveManager {
        id: saveManager
    }
    GameController {
        id: gameController
        Component.onCompleted: gameController.setSettingsManager(settingsManager)
        onGameOver: (msg) => {
            gameController.reportFinalScore()
            saveManager.clear()
            endDialog.message = msg + "　最终得分：" + gameController.currentScore
            endDialog.open()
        }
    }

    Component.onCompleted: root.applyFullscreen()
    function applyFullscreen() {
        if (settingsManager.fullscreen) root.showFullScreen()
        else { root.showNormal(); root.width = 800; root.height = 650; }
    }

    Item {
        id: contentRoot
        anchors.fill: parent

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
            anchors.left: parent.left
            anchors.right: parent.right
            gameController: gameController
            saveManager: saveManager
            focusTarget: battleField
            onSettingsRequested: settingsPanel.open()
        }

        PauseOverlay {
            id: pauseOverlay
            anchors.fill: parent
            gameController: gameController
            onSaveRequested: {
                const snap = gameController.captureSnapshot()
                if (saveManager.writeSnapshot(snap)) gameController.resumeGame()
            }
        }
    }

    EndDialog {
        id: endDialog
    }

    SettingsPanel {
        id: settingsPanel
        settingsManager: settingsManager
        saveManager: saveManager
    }
}
