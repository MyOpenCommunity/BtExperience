import QtQuick 1.1
import Components 1.0

Rectangle {
    id: button

    property bool inputAllowed: true

    signal buttonClicked
    signal buttonPressed
    signal buttonReleased

    width: btn.width
    height: btn.height

    Column{
        SvgImage {
            id: btn
            source: mouseArea.pressed ? "../images/common/button_1-3_p.svg" :
                                        "../images/common/button_1-3.svg"

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                visible: inputAllowed
                onClicked: buttonClicked()
                onPressed: buttonPressed()
                onReleased: buttonReleased()
            }
        }

        SvgImage {
            source: "../images/common/shadow_button_1-3.svg"
            visible: mouseArea.pressed === false
        }
    }
}

