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
import BtExperience 1.0
import Components 1.0
import Components.Text 1.0
import "js/Stack.js" as Stack


/**
  \ingroup Core

  \brief The page that show up when a password is requested.

  If password checking has been enabled, password protected operation can
  execute only if the correct password is entered. This page let the user
  insert a password and then validates it.
  */
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
