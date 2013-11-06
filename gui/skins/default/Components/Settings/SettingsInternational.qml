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
import "../../js/logging.js" as Log
import "../../js/Stack.js" as Stack
import "../../js/EventManager.js" as EventManager


MenuColumn {
    id: column

    Component {
        id: textLanguage
        TextLanguage {}
    }

    Component {
        id: keyboardLanguage
        KeyboardLanguage {}
    }

    // we don't have a ListView, so we don't have a currentIndex property: let's define it
    QtObject {
        id: privateProps
        property int currentIndex: -1
        // -1 -> no selection
        //  1 -> text language menu
        //  2 -> keyboard language menu
        property string language: ''
        property string keyboardLayout: ""

        function showAlert() {
            pageObject.installPopup(alertComponent, {"message": pageObject.names.get('REBOOT', 0)})
        }
    }

    Component {
        id: alertComponent
        Alert {
            onAlertOkClicked: {
                if (privateProps.currentIndex === 1)
                    global.guiSettings.language = privateProps.language
                else if (privateProps.currentIndex === 2)
                    global.keyboardLayout = privateProps.keyboardLayout

                EventManager.eventManager.notificationsEnabled = false
                Stack.backToHome({state: "pageLoading"})
            }
        }
    }

    onChildDestroyed: privateProps.currentIndex = -1
    Connections {
        target: column.child
        ignoreUnknownSignals: true

        // The if() below is needed: we want to avoid going into 'wait for reboot'
        // state in case the C++ property doesn't change value and conf.xml is
        // not written
        onTextLanguageChanged: {
            if (global.guiSettings.language !== config) {
                privateProps.language = config
                privateProps.showAlert()
            }
        }
        onKeyboardLayoutChanged: {
            if (global.keyboardLayout !== config) {
                privateProps.keyboardLayout = config
                privateProps.showAlert()
            }
        }
    }

    Column {
        MenuItem {
            id: textLanguageItem
            name: qsTr("text language")
            description: pageObject.names.get('LANGUAGE', global.guiSettings.language)
            hasChild: true
            isSelected: privateProps.currentIndex === 1
            onTouched: {
                if (privateProps.currentIndex !== 1)
                    privateProps.currentIndex = 1
                column.loadColumn(textLanguage, name)
            }
        }

        MenuItem {
            id: keyboardLanguageItem
            name: qsTr("keyboard language")
            description: pageObject.names.get('KEYBOARD', global.keyboardLayout)
            hasChild: true
            isSelected: privateProps.currentIndex === 2
            onTouched: {
                if (privateProps.currentIndex !== 2)
                    privateProps.currentIndex = 2
                column.loadColumn(keyboardLanguage, name)
            }
        }
    }
}
