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
import "../js/Systems.js" as Script


/**
  \ingroup Core

  \brief A component that implements page skipping functionality.

  This component contains logic to skip the main systems page if only one
  system is defined. It navigates directly to the only system page.
  */
Item {
    /**
      Checks if the to be loaded page has to be skipped or not.
      @return type:array An array containing the page and the properties to load if skipping is needed.
      */
    function pageSkip() {
        if (systemsModel.count === 1) {
            return {"page": Script.getTarget(systemsModel.getObject(0).containerId), "properties": {}}
        }
        return {"page": "", "properties": {}}
    }

    ObjectModel {
        id: systemsModel
        source: myHomeModels.systems
    }

    Component.onCompleted: systemsModel.containers = Script.systemsModelContainers(systemsModel)
}
