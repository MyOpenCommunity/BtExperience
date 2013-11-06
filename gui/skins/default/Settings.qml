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
import Components.Settings 1.0
import BtExperience 1.0
import "js/Stack.js" as Stack


/**
  \brief The Settings system page.
  */
SystemPage {
    source : homeProperties.homeBgImage
    text: qsTr("Settings")
    rootColumn: Component { SettingsItems {} }
    names: SettingsNames {}
    showSystemsButton: false

    /**
      Called when system button on navigation bar is clicked.
      Navigates back to settings page.
      */
    function systemsButtonClicked() {
        Stack.backToOptions()
    }

    /**
      Hook called when MenuContainer is closed.
      Navigates back to HomePage.
      */
    function systemPageClosed() {
        Stack.backToHome()
    }
}
