import QtQuick 1.1
import BtObjects 1.0
import BtExperience 1.0
import Components 1.0
import Components.Text 1.0
import "js/Stack.js" as Stack


BasePage {
    id: control

    source : homeProperties.homeBgImage
    _pageName: "PasswordCheck"

    PasswordInput {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -control.height / 6
        onPasswordConfirmed: confirmPassword(password)
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

    function confirmPassword(password) {
        console.log(password, global.password)
        if (global.password === password)
            global.screenState.unlockScreen()
    }
}
