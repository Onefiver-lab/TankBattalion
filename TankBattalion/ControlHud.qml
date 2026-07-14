import QtQuick
import QtQuick.Controls

Rectangle {
    id: root
    property var gameController
    property var saveManager
    property var focusTarget

    width: parent.width
    height: 60
    color: "#222"

    Row {
        anchors.fill: parent
        anchors.margins: 6
        spacing: 8

        Column {
            spacing: 4
            anchors.verticalCenter: parent.verticalCenter
            Row {
                spacing: 6
                ComboBox {
                    id: modeBox
                    model: ["单人模式", "双人同屏", "PVP对战"]
                    currentIndex: root.gameController ? root.gameController.gameMode : 0
                    onCurrentIndexChanged: if (root.gameController) root.gameController.gameMode = currentIndex
                }
                ComboBox {
                    id: diffBox
                    model: ["简单 (3敌人/无限弹)", "中等 (6敌人/无限弹)", "困难 (12敌人/100弹)", "地狱 (20敌人/50弹)"]
                    visible: modeBox.currentIndex !== 2
                    currentIndex: root.gameController ? root.gameController.difficulty : 0
                    onCurrentIndexChanged: if (root.gameController) root.gameController.difficulty = currentIndex
                }
            }
            Text {
                visible: modeBox.currentIndex !== 2
                color: "#9e9e9e"
                font.pixelSize: 11
                text: "当前分数：" + (root.gameController ? root.gameController.currentScore : 0)
            }
        }

        Item { width: 1 }

        Row {
            spacing: 6
            anchors.verticalCenter: parent.verticalCenter

            Button {
                text: "重新开始"
                onClicked: {
                    if (root.gameController) {
                        if (root.gameController.paused) root.gameController.resumeGame()
                        root.gameController.startGame()
                    }
                    if (root.focusTarget) root.focusTarget.focus = true
                }
            }
            Button {
                text: "继续上局"
                enabled: root.saveManager && root.saveManager.hasSave
                onClicked: {
                    if (!root.saveManager) return
                    const snap = root.saveManager.readSnapshot()
                    if (snap && root.gameController) {
                        root.gameController.restoreSnapshot(snap)
                        if (root.focusTarget) root.focusTarget.focus = true
                    }
                }
            }
            Button {
                text: root.gameController && root.gameController.paused ? "继续游戏" : "暂停"
                onClicked: {
                    if (!root.gameController) return
                    if (root.gameController.paused) root.gameController.resumeGame()
                    else root.gameController.pauseGame()
                    if (root.focusTarget) root.focusTarget.focus = true
                }
            }
            Button {
                text: "设置"
                onClicked: root.settingsRequested()
            }
        }
    }

    signal settingsRequested()
}
