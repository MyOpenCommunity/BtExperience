import QtQuick 1.1

Item {
    id: button

    signal plusClicked
    signal minusClicked

    width: 212
    height: 50

    ButtonImageThreeStates {
        defaultImageBg: "../images/common/button_1-2.svg"
        pressedImageBg: "../images/common/button_1-2_p.svg"
        shadowImage: "../images/common/shadow_button_1-2.svg"
        defaultImage: "../images/common/symbol_minus.svg"
        pressedImage: "../images/common/symbol_minus.svg"
        repetitionOnHold: true
        onPressed: button.minusClicked()
        anchors {
            left: parent.left
            leftMargin: 7
            bottom: parent.bottom
            bottomMargin: 5
        }
    }

    ButtonImageThreeStates {
        defaultImageBg: "../images/common/button_1-2.svg"
        pressedImageBg: "../images/common/button_1-2_p.svg"
        shadowImage: "../images/common/shadow_button_1-2.svg"
        defaultImage: "../images/common/symbol_plus.svg"
        pressedImage: "../images/common/symbol_plus.svg"
        repetitionOnHold: true
        onPressed: button.plusClicked()
        anchors {
            right: parent.right
            rightMargin: 7
            bottom: parent.bottom
            bottomMargin: 5
        }
    }
}
