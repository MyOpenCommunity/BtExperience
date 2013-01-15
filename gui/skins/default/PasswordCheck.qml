import QtQuick 1.1
import BtObjects 1.0
import BtExperience 1.0
import Components 1.0
import Components.Text 1.0
import "js/Stack.js" as Stack


BasePage {
    id: control

    source : global.guiSettings.homeBgImage
    _pageName: "PasswordCheck"

    SvgImage {
        id: passwordRect

        source: "images/scenarios/bg_testo.svg"
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -control.height / 6

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
                anchors.fill: parent
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
                }
            }
        }
    }

    ButtonThreeStates {
        id: confirmButton

        defaultImage: "images/common/btn_99x35.svg"
        pressedImage: "images/common/btn_99x35_P.svg"
        selectedImage: "images/common/btn_99x35_S.svg"
        shadowImage: "images/common/btn_shadow_99x35.svg"
        text: qsTr("Confirm")
        font.pixelSize: 14
        onClicked: control.confirmPassword()
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: passwordRect.bottom
            bottomMargin: 10
        }
    }

    Component.onCompleted: {
        global.screenState.enableState(ScreenState.PasswordCheck)
    }

    Component.onDestruction: {
        global.screenState.disableState(ScreenState.PasswordCheck)
    }

    Connections {
        target: global.screenState
        onStateChanged: {
            if (global.screenState.state !== ScreenState.PasswordCheck &&
                global.screenState.state !== ScreenState.Freeze)
                Stack.popPage()
        }
    }

    function confirmPassword() {
        console.log(password.text, global.password)
        if (global.password === password.text)
            global.screenState.unlockScreen()
        else
            password.text = ''
    }
}
