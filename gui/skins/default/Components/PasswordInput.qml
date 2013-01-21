import QtQuick 1.1
import Components.Text 1.0

SvgImage {
    id: passwordRect

    signal passwordConfirmed(string password)

    source: "../images/scenarios/bg_testo.svg"

    UbuntuMediumText {
        id: text
        anchors.top: parent.top
        anchors.topMargin: 7
        font.pixelSize: 18
        color: "black"
        text: qsTr("Insert security code")
        anchors {
            right: parent.right
            rightMargin: parent.width / 100 * 2
            left: parent.left
            leftMargin: parent.width / 100 * 2
        }
    }

    Rectangle {
        id: passwordRectBg

        width: 300
        height: 30

        anchors.centerIn: parent

        UbuntuMediumTextInput {
            id: password
            font.pixelSize: 14
            color: "black"
            focus: true
            echoMode: TextInput.Password
            horizontalAlignment: Text.AlignHCenter
            anchors {
                right: parent.right
                rightMargin: parent.width / 100 * 2
                left: parent.left
                leftMargin: parent.width / 100 * 2
                verticalCenter: parent.verticalCenter
            }
        }
    }

    ButtonThreeStates {
        id: confirmButton
        anchors {
            horizontalCenter: passwordRect.horizontalCenter
            bottom: passwordRect.bottom
            bottomMargin: 10
        }
        defaultImage: "../images/common/btn_99x35.svg"
        pressedImage: "../images/common/btn_99x35_P.svg"
        selectedImage: "../images/common/btn_99x35_S.svg"
        shadowImage: "../images/common/btn_shadow_99x35.svg"
        text: qsTr("Confirm")
        font.pixelSize: 14
        onClicked: {
            passwordRect.passwordConfirmed(password.text)
            password.text = ""
        }
    }
}
