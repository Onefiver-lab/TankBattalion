import QtQuick
import QtQuick.Controls

Rectangle {
    id: root
    property var gameController
    visible: opacity > 0
    opacity: gameController && gameController.paused ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: 150 } }

    color: "#cc000000"
    anchors.fill: parent
    z: 50

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.AllButtons
        onWheel: (w) => w.accepted = true
    }

    Column {
        anchors.centerIn: parent
        spacing: 14

        Text {
            text: "⏸  已暂停"
            color: "#fff"
            font.pixelSize: 32
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Text {
            text: "按 ESC 或点击「继续」恢复游戏"
            color: "#bbb"
            font.pixelSize: 14
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Column {
            spacing: 8
            anchors.horizontalCenter: parent.horizontalCenter

            Button {
                text: "继续游戏"
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: root.gameController.resumeGame()
            }
            Button {
                text: "保存进度"
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: root.saveRequested()
            }
            Button {
                text: "重新开始"
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    root.gameController.resumeGame()
                    root.gameController.startGame()
                }
            }
        }
    }

    signal saveRequested()
}
