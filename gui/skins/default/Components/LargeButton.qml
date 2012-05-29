import QtQuick 1.1
import Components 1.0

Rectangle {
    id: button

    signal buttonClicked
    signal buttonPressed
    signal buttonReleased

    width: btn.width
    height: btn.height

    Column{
        SvgImage {
            id: btn
            source: mouseArea.pressed ? "../images/common/button_1-2_p.svg" :
                                        "../images/common/button_1-2.svg"

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                onClicked: buttonClicked()
                onPressed: buttonPressed()
                onReleased: buttonReleased()
            }
        }

        SvgImage {
            source: "../images/common/shadow_button_1-2.svg"
            visible: mouseArea.pressed === false
        }
    }
}

