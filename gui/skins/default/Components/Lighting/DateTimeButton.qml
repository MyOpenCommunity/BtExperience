import QtQuick 1.1
import Components 1.0

Rectangle {
    id: button
    width: btn.width
    height: btn.height

    property string text: "-"
    signal buttonClicked

    Column{
        SvgImage {
            id: btn
            source: mouseArea.pressed ? "../../images/common/date_button_press.svg" :
                                        "../../images/common/date_button_background.svg"

            Text {
                text: button.text
                anchors.centerIn: parent
            }
            MouseArea {
                id: mouseArea
                anchors.fill: parent
                onClicked: buttonClicked()
            }
        }

        SvgImage {
            source: "../../images/common/date_button_shadow.svg"
            visible: mouseArea.pressed === false
        }
    }
}
