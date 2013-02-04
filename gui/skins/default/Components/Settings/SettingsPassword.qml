import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Popup 1.0
import "../../js/Stack.js" as Stack


MenuColumn {
    id: column

    Column {
        MenuItem {
            name: qsTr("Change password")
            onClicked: Stack.pushPage("ChangePassword.qml")
        }

        PaginatorList {
            id: paginator
            currentIndex: global.passwordEnabled

            delegate: MenuItemDelegate {
                name: model.name
                onClicked: {
                    // asks for password only when changing value
                    if (global.passwordEnabled === value)
                        return
                    pageObject.installPopup(passwordInput, {newValue: value})
                }
            }

            model: modelList
            onCurrentPageChanged: column.closeColumn()
        }
    }

    Component {
        id: errorFeedback
        FeedbackPopup {
            text: qsTr("Incorrect password")
            isOk: false
        }
    }

    Component {
        id: passwordInput
        PasswordInput {
            property bool newValue
            onPasswordConfirmed: {
                var passOk = true
                if (global.password === password)
                    global.passwordEnabled = newValue
                else {
                    // reset view state
                    paginator.currentIndex = global.passwordEnabled
                    passOk = false
                }
                pageObject.closePopup()
                if (!passOk)
                    feedbackTimer.start()
            }
        }
    }

    Timer {
        id: feedbackTimer
        interval: 200
        repeat: false
        onTriggered: pageObject.installPopup(errorFeedback)
    }

    ListModel {
        id: modelList
    }

    Component.onCompleted: {
        modelList.append({"value": false, "name": pageObject.names.get('PASSWORD', false)})
        modelList.append({"value": true, "name": pageObject.names.get('PASSWORD', true)})
        paginator.currentIndex = global.passwordEnabled
    }
}
