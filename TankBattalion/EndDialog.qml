import QtQuick
import QtQuick.Controls

Dialog {
    id: root
    property string message
    title: "\u6218\u51b5\u7ed3\u7b97"
    anchors.centerIn: parent
    modal: true
    standardButtons: Dialog.Ok

    Label {
        text: root.message
        font.pixelSize: 16
    }
}
