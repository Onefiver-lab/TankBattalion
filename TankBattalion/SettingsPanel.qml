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

    onAboutToShow: {
        if (settingsManager) {
            soundSwitch.checked = settingsManager.soundEnabled
            volumeSlider.value  = settingsManager.soundVolume
            fullscreenSwitch.checked = settingsManager.fullscreen
        }
    }

    contentItem: Column {
        spacing: 14
        padding: 8

        Row {
            spacing: 12
            Switch {
                id: soundSwitch
                text: "启用音效"
                onCheckedChanged: if (root.settingsManager) root.settingsManager.soundEnabled = checked
            }
        }

        Column {
            spacing: 4
            width: parent.width
            Text { text: "音量"; color: "#ddd"; font.pixelSize: 12 }
            Row {
                spacing: 8
                Slider {
                    id: volumeSlider
                    from: 0; to: 100; stepSize: 1
                    width: 240
                    onMoved: if (root.settingsManager) root.settingsManager.soundVolume = value
                }
                Text {
                    text: Math.round(volumeSlider.value) + "%"
                    color: "#ddd"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        Row {
            spacing: 12
            Switch {
                id: fullscreenSwitch
                text: "全屏"
                onCheckedChanged: if (root.settingsManager) root.settingsManager.fullscreen = checked
            }
        }

        Rectangle {
            width: parent.width
            height: 60
            color: "#1e1e1e"
            radius: 6
            border.color: "#333"
            Column {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 2
                Text { text: "历史最高分（任意模式 / 难度）"; color: "#888"; font.pixelSize: 11 }
                Text {
                    text: root.settingsManager ? root.settingsManager.bestScore : 0
                    color: "#00ff66"
                    font.pixelSize: 20
                    font.bold: true
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 70
            color: "#1e1e1e"
            radius: 6
            border.color: "#333"
            visible: root.saveManager !== undefined && root.saveManager !== null
            Column {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 2
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
        }
    }

    Dialog {
        id: confirmClear
        title: "确认"
        modal: true
        anchors.centerIn: parent
        standardButtons: Dialog.Yes | Dialog.No
        Label { text: "确定要清空全部设置与存档吗？此操作不可恢复。" }
        onAccepted: {
            if (root.settingsManager) root.settingsManager.clearAll()
            if (root.saveManager)     root.saveManager.clear()
        }
    }
}
