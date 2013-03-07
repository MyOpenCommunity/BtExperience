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
            right: button.left
            rightMargin: 11
        }
        font.pixelSize: 14
        color: "#323232"
        text: control.text
        elide: Text.ElideRight
    }

    ButtonThreeStates {
        id: button

        text: qsTr("ON")
        defaultImage: "../../images/common/btn_66x35.svg"
        pressedImage: "../../images/common/btn_66x35_P.svg"
        shadowImage: "../../images/common/btn_shadow_66x35.svg"
        onClicked: control.clicked()
        onPressed: control.pressed()
        onReleased: control.released()
        font.pixelSize: 16
        anchors {
            bottom: parent.bottom
            bottomMargin: 12
            right: parent.right
            rightMargin: 7
        }
    }
}
