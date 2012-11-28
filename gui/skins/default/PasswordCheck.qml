import QtQuick 1.1
import BtObjects 1.0
import BtExperience 1.0
import Components 1.0
import Components.Text 1.0
import "js/Stack.js" as Stack


BasePage {
    id: control

    source : global.guiSettings.skin === GuiSettings.Clear ? "images/home/home.jpg" :
                                                             "images/home/home_dark.jpg"

    Rectangle {
        id: passwordRect

        width: 300
        height: 20

        anchors.centerIn: parent

        UbuntuMediumTextInput {
            id: password
            anchors.fill: parent
            echoMode: TextInput.Password
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
            top: passwordRect.bottom
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
            if (global.screenState.state !== ScreenState.PasswordCheck)
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
