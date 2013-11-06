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
import "js/array.js" as Script

QtObject {
    // internal function to load values into the container
    function _init(container) {
        container[Container.IdScenarios] = qsTr("Scenarios")
        container[Container.IdLights] = qsTr("lighting")
        container[Container.IdAutomation] = qsTr("automation")
        container[Container.IdAirConditioning] = qsTr("temperature control")
        container[Container.IdLoadControl] = qsTr("Energy management")
        container[Container.IdSupervision] = qsTr("Energy management")
        container[Container.IdEnergyData] = qsTr("Energy management")
        container[Container.IdThermalRegulation] = qsTr("temperature control")
        container[Container.IdVideoDoorEntry] = qsTr("video door entry")
        container[Container.IdSoundDiffusionMulti] = qsTr("Sound System")
        container[Container.IdAntintrusion] = qsTr("Burglar alarm")
        container[Container.IdMessages] = qsTr("messages")
        container[Container.IdSoundDiffusionMono] = qsTr("Sound System")
    }

    /**
      Retrieves the requested value from the local array.
      @param type:int containerId The id of the container.
      */
    function get(containerId) {
        if (Script.container.length === 0)
            _init(Script.container)

        return Script.container[containerId]
    }
}
