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
import Components 1.0
import Components.Antintrusion 1.0
import BtObjects 1.0
import "js/datetime.js" as DateTime


/**
  \ingroup Antintrusion

  \brief The Antintrusion system page.
  */
SystemPage {
    id: antintrusion
    source: "images/background/burglar_alarm.jpg"
    text: systemNames.get(Container.IdAntintrusion)
    rootColumn: Component { AntintrusionSystem {} }
    names: AntintrusionNames { }

    // KeyPad management and API
    function showKeyPad(title, errorMessage, okMessage) {
        installPopup(keypadComponent, {"mainLabel": title, "errorLabel": errorMessage, "okLabel": okMessage})
    }

    function closeKeyPad() {
        closePopup()
    }

    function resetKeyPad() {
        popupLoader.item.textInserted = ""
        popupLoader.item.state = ""
    }

    Component {
        id: keypadComponent
        KeyPad {
            helperLabel: qsTr("enter code")
        }
    }
}

