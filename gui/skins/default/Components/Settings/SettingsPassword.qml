/*
 * Copyright © 2011-2013 BTicino S.p.A.
 *
 * This file is part of BtExperience.
 *
 * BtExperience is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BtExperience is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BtExperience. If not, see <http://www.gnu.org/licenses/>.
 */

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
