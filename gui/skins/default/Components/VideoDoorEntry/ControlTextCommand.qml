/**
  * A control that implements a text and a button 3 states to perform a command.
  * The text is on the left, the button is on the right.
  */

import QtQuick 1.1
import Components 1.0
import Components.Text 1.0


SvgImage {
    id: control

    property string text: "cancelletto"
    property alias defaultImage: button.defaultImage
    property alias pressedImage: button.pressedImage

    signal clicked
    signal pressed
    signal released

    source: "../../images/common/bg_automazioni.svg"

    UbuntuMediumText {
        id: caption

        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: 11
        }
        font.pixelSize: 14
        color: "gray"
        text: control.text
    }

    ButtonImageThreeStates {
        id: button

        defaultImageBg: "../../images/common/btn_66x35.svg"
        pressedImageBg: "../../images/common/btn_66x35_P.svg"
        shadowImage: "../../images/common/btn_shadow_66x35.svg"
        defaultImage: "../../images/common/ico_cancelletto.svg"
        pressedImage: "../../images/common/ico_cancelletto_P.svg"
        onClicked: control.clicked()
        onPressed: control.pressed()
        onReleased: control.released()
        status: 0
        anchors {
            bottom: parent.bottom
            bottomMargin: 12
            right: parent.right
            rightMargin: 7
        }
    }
}
