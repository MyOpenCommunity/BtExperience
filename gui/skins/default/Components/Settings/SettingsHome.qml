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
import "../../js/default.js" as Default

MenuColumn {
    id: column

    Component {
        id: skin
        SettingsSkin {}
    }

    Component {
        id: quicklinks
        SettingsHomeQuicklinks {}
    }

    QtObject {
        id: privateProps
        property int currentIndex: -1

    }

    Connections {
        target: homeProperties
        onSkinChanged: skinItem.description = pageObject.names.get('SKIN', homeProperties.skin)
    }

    onChildDestroyed: privateProps.currentIndex = -1

    Column {
        id: paginator

        MenuItem {
            id: skinItem
            name: qsTr("Home page skin")
            description: pageObject.names.get('SKIN', homeProperties.skin)
            hasChild: true
            isSelected: privateProps.currentIndex === 1
            onTouched: {
                if (privateProps.currentIndex !== 1)
                    privateProps.currentIndex = 1
                column.loadColumn(skin, name)
            }
        }

        MenuItem {
            name: qsTr("Change background image")
            hasChild: true
            isSelected: privateProps.currentIndex === 2
            onTouched: {
                if (privateProps.currentIndex !== 2)
                    privateProps.currentIndex = 2
                column.loadColumn(settingsImageBrowser, qsTr("Background image"), column.dataModel, {homeCustomization: true})
            }
        }

        MenuItem {
            name: qsTr("Restore background image")
            isSelected: privateProps.currentIndex === 3
            onTouched: {
                privateProps.currentIndex = -1
                pageObject.installPopup(okCancelDialogRestore)
            }
        }

        MenuItem {
            name: qsTr("Quicklinks")
            isSelected: privateProps.currentIndex === 4
            hasChild: true
            onTouched: {
                if (privateProps.currentIndex !== 4)
                    privateProps.currentIndex = 4
                column.loadColumn(quicklinks, qsTr("Quicklinks"))
            }
        }
     }

    Component {
        id: settingsImageBrowser
        SettingsImageBrowser {}
    }

    Component {
        id: okCancelDialogRestore

        TextDialog {
            title: qsTr("Confirm operation")
            text: qsTr("Do you want to restore background to default value?")

            function okClicked() {
                homeProperties.homeBgImage = Default.getDefaultHomeBg()
                column.closeColumn()
            }
        }
    }
}
