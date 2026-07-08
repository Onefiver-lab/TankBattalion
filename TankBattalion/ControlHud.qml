import QtQuick
import QtQuick.Controls

Rectangle {
    id: root
    property var gameController
    property var focusTarget

    width: parent.width
    height: 50
    color: "#222"

    Row {
        anchors.centerIn: parent
        spacing: 12

        ComboBox {
            id: modeBox
            model: ["\u5355\u4eba\u6a21\u5f0f", "\u53cc\u4eba\u540c\u5c4f", "PVP\u5bf9\u6218"]
            currentIndex: root.gameController.gameMode
            onCurrentIndexChanged: root.gameController.gameMode = currentIndex
        }

        ComboBox {
            id: diffBox
            model: ["\u7b80\u5355 (3\u654c\u4eba/\u65e0\u9650\u5f39)", "\u4e2d\u7b49 (6\u654c\u4eba/\u65e0\u9650\u5f39)", "\u56f0\u96be (12\u654c\u4eba/100\u5f39)", "\u5730\u72f1 (20\u654c\u4eba/50\u5f39)"]
            visible: modeBox.currentIndex !== 2
            currentIndex: root.gameController.difficulty
            onCurrentIndexChanged: root.gameController.difficulty = currentIndex
        }

        Button {
            text: "\u91cd\u6574\u6218\u5c40\u5e76\u542f\u52a8"
            onClicked: {
                root.gameController.startGame()
                if (root.focusTarget) root.focusTarget.focus = true
            }
        }
    }
}
