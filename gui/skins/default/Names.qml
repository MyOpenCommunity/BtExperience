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
import "js/array.js" as Script


/**
  \ingroup Core

  \brief Component containing all translations.
  */
Item {
    AntintrusionNames {
        id: antintrusionNames
    }

    EnergyManagementNames {
        id: energyManagementNames
    }

    LightingNames {
        id: lightingNames
    }

    SettingsNames {
        id: settingsNames
    }

    ThermalNames {
        id: thermalNames
    }

    // internal function to load values into the container
    function _init(container) {
        antintrusionNames._init(container)
        energyManagementNames._init(container)
        lightingNames._init(container)
        settingsNames._init(container)
        thermalNames._init(container)
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
