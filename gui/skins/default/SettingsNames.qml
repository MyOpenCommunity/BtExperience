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
import "js/array.js" as Script


/**
  \ingroup Core

  \brief Translations for the Settings system.
  */
QtObject {
    // internal function to load values into the container
    function _init(container) {
        container['REBOOT'] = []
        container['REBOOT'][0] = qsTr("Pressing ok will cause a device reboot in a few moments.\nContinue?")

        container['CONFIG'] = []
        container['CONFIG'][PlatformSettings.Dhcp] = qsTr("DHCP")
        container['CONFIG'][PlatformSettings.Static] = qsTr("Static IP address")

        container['STATE'] = []
        container['STATE'][PlatformSettings.Enabled] = qsTr("Connect")
        container['STATE'][PlatformSettings.Disabled] = qsTr("Disconnect")

        container['AUTO_UPDATE'] = []
        container['AUTO_UPDATE'][true] = qsTr("Enabled")
        container['AUTO_UPDATE'][false] = qsTr("Disabled")

        container['LANGUAGE'] = []
        container['LANGUAGE']["it"] = qsTr("Italian")
        container['LANGUAGE']["en"] = qsTr("English")
        container['LANGUAGE']["fr"] = qsTr("French")
        container['LANGUAGE']["de"] = qsTr("German")
        container['LANGUAGE']["nl"] = qsTr("Dutch")
        container['LANGUAGE']["es"] = qsTr("Spanish")
        container['LANGUAGE']["pt"] = qsTr("Portuguese")
        container['LANGUAGE']["el"] = qsTr("Greek")
        container['LANGUAGE']["ru"] = qsTr("Russian")
        container['LANGUAGE']["tr"] = qsTr("Turkish")
        container['LANGUAGE']["pl"] = qsTr("Polish")
        container['LANGUAGE']["zh_CN"] = qsTr("Simplified Chinese")

        container['KEYBOARD'] = []
        container['KEYBOARD']["it_bticino"] = qsTr("Italian")
        container['KEYBOARD']["en_bticino"] = qsTr("English")
        container['KEYBOARD']["fr_bticino"] = qsTr("French")
        container['KEYBOARD']["it"] = qsTr("Italian")
        container['KEYBOARD']["en"] = qsTr("English")
        container['KEYBOARD']["fr"] = qsTr("French")

        container['SKIN'] = []
        container['SKIN'][HomeProperties.Clear] = qsTr("Clear")
        container['SKIN'][HomeProperties.Dark] = qsTr("Dark")

        container['PASSWORD'] = []
        container['PASSWORD'][false] = qsTr("Disable")
        container['PASSWORD'][true] = qsTr("Enable")

        container['BEEP'] = []
        container['BEEP'][true] = qsTr("Enabled")
        container['BEEP'][false] = qsTr("Disabled")

        container['BROWSER_HISTORY'] = []
        container['BROWSER_HISTORY'][true] = qsTr("Enabled")
        container['BROWSER_HISTORY'][false] = qsTr("Disabled")

        container['HANDS_FREE'] = []
        container['HANDS_FREE'][true] = qsTr("Enabled")
        container['HANDS_FREE'][false] = qsTr("Disabled")

        container['AUTO_OPEN'] = []
        container['AUTO_OPEN'][true] = qsTr("Enabled")
        container['AUTO_OPEN'][false] = qsTr("Disabled")

        container['RING_EXCLUSION'] = []
        container['RING_EXCLUSION'][true] = qsTr("Enabled")
        container['RING_EXCLUSION'][false] = qsTr("Disabled")
    }

    /**
      Retrieves the requested value from the local array.
      @param type:string context The translation context to distinguish between similar id.
      @param type:int id The id referring to the string to be translated.
      */
    function get(context, id) {
        if (Script.container.length === 0)
            _init(Script.container)

        return Script.container[context][id]
    }
}
