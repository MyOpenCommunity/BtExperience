import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Popup 1.0
import "../../js/Stack.js" as Stack
import "../../js/EventManager.js" as EventManager


MenuColumn {
    id: column

    Column {
        MenuItem {
            name: qsTr("Change password")
            onTouched: Stack.pushPage("ChangePassword.qml")
        }

        PaginatorList {
            id: paginator

            delegate: MenuItemDelegate {
                name: model.name
                selectOnClick: false
                onDelegateTouched: {
                    // asks for password only when changing value
                    if (global.passwordEnabled === value)
                        return
                    pageObject.installPopup(passwordInput, {newValue: value})
                }
            }

            elementsOnPage: elementsOnMenuPage - 1
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

    QtObject {
        id: privateProps

        property bool pass
    }

    Component {
        id: alertComponent
        Alert {
            onAlertOkClicked:  {
                global.passwordEnabled = privateProps.pass
                EventManager.eventManager.notificationsEnabled = false
                Stack.backToHome({state: "pageLoading"})
            }
        }
    }

    Component {
        id: passwordInput
        PasswordInput {
            property bool newValue
            onPasswordConfirmed: {
                if (global.password === password) {
                    privateProps.pass = newValue
                    pageObject.closePopup()
                    pageObject.installPopup(alertComponent, {"message": pageObject.names.get('REBOOT', 0)})
                    return
                }

                pageObject.closePopup()
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
    }
}
