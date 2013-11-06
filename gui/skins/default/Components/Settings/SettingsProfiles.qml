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
import "../../js/navigationconstants.js" as NavigationConstants


MenuColumn {
    id: column

    ObjectModel {
        id: profilesModel
        source: myHomeModels.profiles
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    onChildDestroyed: paginator.currentIndex = -1

    // needed for menu navigation
    function targetsKnown() {
        return {
            "Profile": privateProps.openProfileMenu,
        }
    }

    QtObject {
        id: privateProps

        property int currentIndex: -1

        function openProfileMenu(navigationData) {
            var absIndex = profilesModel.getAbsoluteIndexOf(navigationData)
            if (absIndex === -1)
                return NavigationConstants.NAVIGATION_PROFILE_NOT_FOUND
            paginator.openDelegate(absIndex, paginator.openColumn)
            return NavigationConstants.NAVIGATION_FINISHED_OK
        }
    }

    Column {
        MenuItem {
            name: qsTr("Add Profile")
            enabled: profilesModel.count < 10
            onTouched: {
                if (privateProps.currentIndex !== 1) {
                    privateProps.currentIndex = 1
                    if (column.child)
                        column.closeChild()
                    paginator.currentIndex = -1
                }
                pageObject.installPopup(popupAddProfile)
            }
            Component {
                id: popupAddProfile
                FavoriteEditPopup {
                    title: qsTr("Insert new profile name")
                    topInputLabel: qsTr("New Name:")
                    topInputText: ""
                    bottomVisible: false

                    function okClicked() {
                        myHomeModels.createProfile(topInputText)
                    }
                }
            }
        }

        PaginatorList {
            id: paginator

            elementsOnPage: elementsOnMenuPage - 1
            currentIndex: -1
            model: profilesModel
            onCurrentPageChanged: column.closeChild()

            delegate: MenuItemDelegate {
                itemObject: profilesModel.getObject(index)
                hasChild: true
                name: itemObject.description
                onDelegateTouched: {
                    privateProps.currentIndex = -1
                    openColumn(itemObject)
                }
            }

            function openColumn(itemObject) {
                column.loadColumn(settingsProfileComponent, itemObject.description, itemObject)
            }
        }
    }

    Component {
        id: settingsProfileComponent
        SettingsProfile {}
    }
}
