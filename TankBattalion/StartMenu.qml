import QtQuick
import QtQuick.Controls

Item {
    id: root
    property int selectedMode: 0
    property int selectedDifficulty: 0

    signal startGame(int mode, int difficulty)
    signal openSettings()

    Rectangle {
        anchors.fill: parent
        color: "#0d0d0d"
    }

    Column {
        id: menuColumn
        anchors.centerIn: parent
        width: 400
        spacing: 24

        Column {
            width: parent.width
            spacing: 8

            Text {
                text: "坦克大战"
                font.pixelSize: 48
                font.bold: true
                color: "#2a9d8f"
                anchors.horizontalCenter: parent.horizontalCenter
                font.family: "Microsoft YaHei, SimHei, sans-serif"
            }

            Text {
                text: "TANK BATTALION"
                font.pixelSize: 14
                color: "#666"
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: "#333"
        }

        Column {
            width: parent.width
            spacing: 8

            Text {
                text: "游戏模式"
                color: "#aaa"
                font.pixelSize: 13
            }

            Row {
                id: modeRow
                width: parent.width
                spacing: 8

                Repeater {
                    model: ["单人模式", "双人合作", "PVP 对战"]

                    Rectangle {
                        width: (modeRow.width - 16) / 3
                        height: 40
                        radius: 4
                        color: selectedMode === index ? "#2a9d8f" : "#1e1e1e"
                        border.color: selectedMode === index ? "#2a9d8f" : "#444"
                        border.width: 1

                        Text {
                            text: modelData
                            color: selectedMode === index ? "#fff" : "#ccc"
                            font.pixelSize: 12
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: root.selectedMode = index
                            cursorShape: Qt.PointingHandCursor
                        }
                    }
                }
            }
        }

        Column {
            width: parent.width
            spacing: 8

            Text {
                text: "难度选择"
                color: "#aaa"
                font.pixelSize: 13
            }

            Row {
                id: diffRow
                width: parent.width
                spacing: 8

                Repeater {
                    model: ["简单", "中等", "困难", "地狱"]

                    Rectangle {
                        width: (diffRow.width - 24) / 4
                        height: 36
                        radius: 4
                        color: selectedDifficulty === index ? "#e76f51" : "#1e1e1e"
                        border.color: selectedDifficulty === index ? "#e76f51" : "#444"
                        border.width: 1

                        Text {
                            text: modelData
                            color: selectedDifficulty === index ? "#fff" : "#ccc"
                            font.pixelSize: 12
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: root.selectedDifficulty = index
                            cursorShape: Qt.PointingHandCursor
                        }
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: "#333"
        }

        Column {
            width: parent.width
            spacing: 12

            Rectangle {
                width: parent.width
                height: 48
                radius: 6
                color: startBtn.pressed ? "#1e7a6f" : (startBtn.hovered ? "#3abba6" : "#2a9d8f")

                Text {
                    text: "开始游戏"
                    color: "#fff"
                    font.pixelSize: 16
                    font.bold: true
                    anchors.centerIn: parent
                }

                MouseArea {
                    id: startBtn
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.startGame(root.selectedMode, root.selectedDifficulty)
                }
            }

            Rectangle {
                width: parent.width
                height: 40
                radius: 6
                color: settingsBtn.pressed ? "#1e1e1e" : (settingsBtn.hovered ? "#2a2a2a" : "#1a1a1a")
                border.color: "#444"
                border.width: 1

                Text {
                    text: "游戏设置"
                    color: "#ccc"
                    font.pixelSize: 13
                    anchors.centerIn: parent
                }

                MouseArea {
                    id: settingsBtn
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.openSettings()
                }
            }
        }

        Text {
            text: "P1: WASD 移动 · 空格射击　　P2: 方向键 · 回车射击"
            color: "#555"
            font.pixelSize: 11
            anchors.horizontalCenter: parent.horizontalCenter
            wrapMode: Text.WordWrap
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Rectangle {
        id: tankDeco1
        width: 24
        height: 24
        color: "#2a9d8f"
        opacity: 0.3
        rotation: 45
        x: 40
        y: 60
    }

    Rectangle {
        id: tankDeco2
        width: 16
        height: 16
        color: "#e76f51"
        opacity: 0.3
        rotation: 45
        x: parent.width - 60
        y: 100
    }

    Rectangle {
        id: tankDeco3
        width: 20
        height: 20
        color: "#e9c46a"
        opacity: 0.2
        rotation: 45
        x: 80
        y: parent.height - 80
    }
}
