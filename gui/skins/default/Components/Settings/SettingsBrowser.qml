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


MenuColumn {
    id: column

    QtObject {
        id: privateProps
        property int currentIndex: -1
    }

    onChildDestroyed: {
        privateProps.currentIndex = -1
    }

    Column {
        MenuItem {
            id: homePageItem
            name: qsTr("Change Home Page")
            onTouched: {
                if (privateProps.currentIndex !== 1)
                    privateProps.currentIndex = 1
                column.closeChild()
                pageObject.installPopup(popupEditUrl)
            }
            Component {
                id: popupEditUrl
                FavoriteEditPopup {
                    title: qsTr("Insert new home page")
                    topInputLabel: qsTr("New URL:")
                    topInputText: global.homePageUrl
                    bottomVisible: false

                    function okClicked() {
                        global.homePageUrl = topInputText
                    }
                }
            }
        }

        MenuItem {
            id: historyItem
            name: qsTr("Enable history")
            description: global.keepingHistory ? qsTr("Enabled") : qsTr("Disabled")
            hasChild: true
            isSelected: privateProps.currentIndex === 2
            onTouched: {
                if (privateProps.currentIndex !== 2)
                    privateProps.currentIndex = 2
                column.loadColumn(historyComponent, name)
            }

            Component {
                id: historyComponent
                SettingsHistory {
                }
            }
        }

        MenuItem {
            id: clearHistoryItem
            name: qsTr("Clear History")
            onTouched: {
                if (privateProps.currentIndex !== 3)
                    privateProps.currentIndex = 3
                column.closeChild()
                pageObject.installPopup(alertComponent, {"message": qsTr("Pressing ok will delete all browser history.\nContinue?")})
            }
        }

        Component {
            id: alertComponent
            Alert {
                onAlertOkClicked: {
                    global.deleteHistory()
                }
            }
        }
    }
}

