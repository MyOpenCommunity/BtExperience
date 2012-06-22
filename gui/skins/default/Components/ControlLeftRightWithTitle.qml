import QtQuick 1.1
import Components.Text 1.0


SvgImage {
    id: control

    property string text: "7 seconds"
    property string title: "temperature"

    signal leftClicked
    signal rightClicked

    source: "../images/termo/selettore/bg_selettore.svg"

    UbuntuLightText {
        id: title
        color: "black"
        text: control.title
        font.pixelSize: 13
        anchors {
            top: parent.top
            topMargin: 5
            left: parent.left
            leftMargin: 7
        }
    }

    ControlLeftRight {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        onLeftClicked: control.leftClicked()
        onRightClicked: control.rightClicked()
        text: control.text
    }
}
