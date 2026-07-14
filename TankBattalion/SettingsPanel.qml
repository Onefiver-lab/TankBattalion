import QtQuick
import QtQuick.Controls

Dialog {
    id: root
    property var settingsManager
    property var saveManager

    title: "设置"
    modal: true
    anchors.centerIn: parent
    standardButtons: Dialog.Close
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

    onAboutToShow: {
        if (settingsManager) {
            soundSwitch.checked = settingsManager.soundEnabled
            volumeSlider.value  = settingsManager.soundVolume
            fullscreenSwitch.checked = settingsManager.fullscreen
        }
    }

    contentItem: Column {
        spacing: 16
        padding: 8
        width: parent.width

        Row {
            spacing: 12
            Switch {
                id: soundSwitch
                text: "启用音效"
                onCheckedChanged: if (root.settingsManager) root.settingsManager.soundEnabled = checked

                contentItem: Text {
                    text: soundSwitch.text
                    font: soundSwitch.font
                    color: "#eee"
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: soundSwitch.indicator.width + soundSwitch.spacing
                }
            }
        }

        Column {
            spacing: 6
            width: parent.width
            Text { text: "音量"; color: "#ddd"; font.pixelSize: 12 }
            Row {
                spacing: 8
                Slider {
                    id: volumeSlider
                    from: 0; to: 100; stepSize: 1
                    width: 240
                    onMoved: if (root.settingsManager) root.settingsManager.soundVolume = value

                    background: Rectangle {
                        x: volumeSlider.leftPadding
                        y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                        width: volumeSlider.availableWidth
                        height: 4
                        radius: 2
                        color: "#444"

                        Rectangle {
                            width: volumeSlider.visualPosition * parent.width
                            height: parent.height
                            color: "#2a9d8f"
                            radius: 2
                        }
                    }
                    handle: Rectangle {
                        x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
                        y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                        width: 14
                        height: 14
                        radius: 7
                        color: "#eee"
                        border.color: "#2a9d8f"
                    }
                }
                Text {
                    text: Math.round(volumeSlider.value) + "%"
                    color: "#ddd"
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 12
                }
            }
        }

        Row {
            spacing: 12
            Switch {
                id: fullscreenSwitch
                text: "全屏"
                onCheckedChanged: if (root.settingsManager) root.settingsManager.fullscreen = checked

                contentItem: Text {
                    text: fullscreenSwitch.text
                    font: fullscreenSwitch.font
                    color: "#eee"
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: fullscreenSwitch.indicator.width + fullscreenSwitch.spacing
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 70
            color: "#252525"
            radius: 6
            border.color: "#333"
            Column {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 4
                Text { text: "历史最高分（任意模式 / 难度）"; color: "#888"; font.pixelSize: 11 }
                Text {
                    text: root.settingsManager ? root.settingsManager.bestScore : 0
                    color: "#00ff66"
                    font.pixelSize: 24
                    font.bold: true
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 80
            color: "#252525"
            radius: 6
            border.color: "#333"
            visible: root.saveManager !== undefined && root.saveManager !== null
            Column {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 4
                Text { text: "上次保存"; color: "#888"; font.pixelSize: 11 }
                Text {
                    text: root.saveManager && root.saveManager.hasSave
                          ? root.saveManager.summary
                          : "（暂无存档）"
                    color: "#fff"
                    font.pixelSize: 13
                    elide: Text.ElideRight
                    width: parent.width
                }
                Text {
                    text: root.saveManager && root.saveManager.hasSave ? root.saveManager.savedAt : ""
                    color: "#666"
                    font.pixelSize: 10
                }
            }
        }

        Button {
            text: "清空全部设置与存档"
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: confirmClear.open()

            background: Rectangle {
                color: parent.pressed ? "#e63946" : (parent.hovered ? "#5a3030" : "#2a2a2a")
                border.color: "#444"
                radius: 4
                Behavior on color { ColorAnimation { duration: 100 } }
            }
            contentItem: Text {
                text: parent.text
                color: "#eee"
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    Dialog {
        id: confirmClear
        title: "确认"
        modal: true
        anchors.centerIn: parent
        standardButtons: Dialog.Yes | Dialog.No

        background: Rectangle {
            color: "#1e1e1e"
            border.color: "#444"
            border.width: 1
            radius: 8
        }

        header: Rectangle {
            color: "#2a2a2a"
            height: 40
            radius: 8
            Text {
                text: confirmClear.title
                color: "#fff"
                font.pixelSize: 15
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 14
            }
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: "#444"
            }
        }

        contentItem: Label {
            text: "确定要清空全部设置与存档吗？此操作不可恢复。"
            color: "#eee"
            padding: 10
        }

        onAccepted: {
            if (root.settingsManager) root.settingsManager.clearAll()
            if (root.saveManager)     root.saveManager.clear()
        }
    }
}
