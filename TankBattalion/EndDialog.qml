import QtQuick
import QtQuick.Controls

Dialog {
    id: root
    property string message
    title: "战况结算"
    anchors.centerIn: parent
    modal: true
    width: 360

    background: Rectangle {
        color: "#1e1e1e"
        border.color: "#444"
        border.width: 1
        radius: 8
    }

    header: Rectangle {
        color: "#2a2a2a"
        height: 44
        radius: 8

        Text {
            text: root.title
            color: "#fff"
            font.pixelSize: 16
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 16
        }

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: "#444"
        }
    }

    contentItem: Column {
        id: contentCol
        width: root.width - 32
        spacing: 20
        topPadding: 8
        bottomPadding: 4

        Text {
            text: root.message
            font.pixelSize: 15
            color: "#eee"
            wrapMode: Text.WordWrap
            width: parent.width
        }

        Row {
            anchors.right: parent.right
            spacing: 8

            Button {
                id: menuBtn
                text: "返回菜单"
                height: 34
                width: 96
                onClicked: root.backToMenuRequested()

                background: Rectangle {
                    color: menuBtn.pressed ? "#3a3a3a" : (menuBtn.hovered ? "#2a2a2a" : "#1e1e1e")
                    border.color: "#444"
                    radius: 4
                }
                contentItem: Text {
                    text: menuBtn.text
                    color: "#ccc"
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Button {
                id: restartBtn
                text: "再来一局"
                height: 34
                width: 96
                onClicked: root.restartRequested()

                background: Rectangle {
                    color: restartBtn.pressed ? "#3a5a50" : (restartBtn.hovered ? "#2a3a35" : "#2a2a2a")
                    border.color: "#444"
                    radius: 4
                }
                contentItem: Text {
                    text: restartBtn.text
                    color: "#eee"
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Button {
                id: okBtn
                text: "确定"
                height: 34
                width: 80
                onClicked: root.close()

                background: Rectangle {
                    color: okBtn.pressed ? "#2a9d8f" : (okBtn.hovered ? "#3abba6" : "#2a9d8f")
                    opacity: okBtn.pressed ? 0.7 : (okBtn.hovered ? 1 : 0.9)
                    border.color: "#2a9d8f"
                    radius: 4
                }
                contentItem: Text {
                    text: okBtn.text
                    color: "#fff"
                    font.pixelSize: 12
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }

    signal restartRequested()
    signal backToMenuRequested()
}