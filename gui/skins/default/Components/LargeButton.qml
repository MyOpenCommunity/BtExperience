import QtQuick 1.1
import Components 1.0

Rectangle {
    id: button
    width: btn.width
    height: btn.height

    signal buttonClicked
    signal buttonPressed
    signal buttonReleased

    Column{
        SvgImage {
            id: btn
            source: mouseArea.pressed ? "../images/common/button_background_press.svg" :
                                        "../images/common/button_background.svg"

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                onClicked: buttonClicked()
                onPressed: buttonPressed()
                onReleased: buttonReleased()
            }
        }

        SvgImage {
            source: "../images/common/button_shadow.svg"
            visible: mouseArea.pressed === false
        }
    }
}

