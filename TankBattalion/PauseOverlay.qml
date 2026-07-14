import QtQuick
import QtQuick.Controls

Rectangle {
    id: root
    property var gameController
    visible: opacity > 0
    opacity: gameController && gameController.paused ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }

    color: "#dd000000"
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
        spacing: 18

        Rectangle {
            width: 80
            height: 80
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#2a2a2a"
            radius: 40
            border.color: "#444"
            border.width: 2

            Text {
                text: "⏸"
                color: "#fff"
                font.pixelSize: 36
                anchors.centerIn: parent
            }
        }

        Text {
            text: "已暂停"
            color: "#fff"
            font.pixelSize: 28
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Text {
            text: "按 ESC 或点击「继续」恢复游戏"
            color: "#aaa"
            font.pixelSize: 14
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Column {
            spacing: 10
            anchors.horizontalCenter: parent.horizontalCenter
            width: 200

            Button {
                text: "继续游戏"
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                height: 40
                onClicked: root.gameController.resumeGame()

                background: Rectangle {
                    color: parent.pressed ? "#2a9d8f" : (parent.hovered ? "#3a5a50" : "#2a2a2a")
                    border.color: "#444"
                    radius: 6
                    Behavior on color { ColorAnimation { duration: 100 } }
                }
                contentItem: Text {
                    text: parent.text
                    color: "#eee"
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
            Button {
                text: "保存进度"
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                height: 40
                onClicked: root.saveRequested()

                background: Rectangle {
                    color: parent.pressed ? "#2a9d8f" : (parent.hovered ? "#3a5a50" : "#2a2a2a")
                    border.color: "#444"
                    radius: 6
                    Behavior on color { ColorAnimation { duration: 100 } }
                }
                contentItem: Text {
                    text: parent.text
                    color: "#eee"
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
            Button {
                text: "重新开始"
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                height: 40
                onClicked: {
                    root.gameController.resumeGame()
                    root.gameController.startGame()
                }

                background: Rectangle {
                    color: parent.pressed ? "#e63946" : (parent.hovered ? "#5a3030" : "#2a2a2a")
                    border.color: "#444"
                    radius: 6
                    Behavior on color { ColorAnimation { duration: 100 } }
                }
                contentItem: Text {
                    text: parent.text
                    color: "#eee"
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }

    signal saveRequested()
}
