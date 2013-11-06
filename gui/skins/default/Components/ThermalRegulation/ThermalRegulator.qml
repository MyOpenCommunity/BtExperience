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
import Components.ThermalRegulation 1.0
import "../../js/MenuItem.js" as Script

MenuColumn {
    id: column

    onChildDestroyed: paginator.currentIndex = -1

    Component { id: thermalControlUnit; ThermalControlUnit {} }
    Component { id: thermalControlledProbe; ThermalControlledProbe {} }

    SystemsModel { id: systemsModel; systemId: Container.IdThermalRegulation }

    ObjectModel {
        id: modelList
        filters: [
            {objectId: ObjectInterface.IdThermalControlUnit99, objectKey: column.dataModel.objectKey},
            {objectId: ObjectInterface.IdThermalControlUnit4, objectKey: column.dataModel.objectKey},
            {objectId: ObjectInterface.IdThermalControlledProbe, objectKey: column.dataModel.objectKey},
            {objectId: ObjectInterface.IdThermalControlledProbeFancoil, objectKey: column.dataModel.objectKey}
        ]
        containers: [systemsModel.systemUii]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    PaginatorList {
        id: paginator
        currentIndex: -1

        elementsOnPage: elementsOnMenuPage
        delegate: MenuItemDelegate {
            itemObject: modelList.getObject(index)
            description: Script.description(itemObject)
            hasChild: Script.hasChild(itemObject)
            onDelegateTouched: {
                var oid = itemObject.objectId
                if (oid === ObjectInterface.IdThermalControlUnit99)
                    column.loadColumn(thermalControlUnit, itemObject.name, itemObject)
                if (oid === ObjectInterface.IdThermalControlUnit4)
                    column.loadColumn(thermalControlUnit, itemObject.name, itemObject)
                if (oid === ObjectInterface.IdThermalControlledProbe)
                    column.loadColumn(thermalControlledProbe, itemObject.name, itemObject)
                if (oid === ObjectInterface.IdThermalControlledProbeFancoil)
                    column.loadColumn(thermalControlledProbe, itemObject.name, itemObject)
            }
            boxInfoState: Script.boxInfoState(itemObject)
            boxInfoText: Script.boxInfoText(itemObject)
        }

        model: modelList
        onCurrentPageChanged: column.closeChild()
    }
}

