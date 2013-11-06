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
import BtObjects 1.0
import "../../js/MenuItem.js" as Script

MenuColumn {
    id: column

    onChildDestroyed: paginator.currentIndex = -1

    BtObjectsMapping { id: mapping }

    SystemsModel { id: thermalRegulation; systemId: Container.IdAirConditioning }
    ObjectModel {
        id: objectModel
        filters: [
            {objectId: ObjectInterface.IdSplitBasicScenario},
            {objectId: ObjectInterface.IdSplitAdvancedScenario},
            {objectId: ObjectInterface.IdSplitBasicGenericCommandGroup},
            {objectId: ObjectInterface.IdSplitAdvancedGenericCommandGroup},
        ]
        containers: [thermalRegulation.systemUii]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    PaginatorList {
        id: paginator

        elementsOnPage: elementsOnMenuPage
        delegate: MenuItemDelegate {
            itemObject: objectModel.getObject(index)
            selectOnClick: itemObject.objectId === ObjectInterface.IdSplitBasicScenario ||
                           itemObject.objectId === ObjectInterface.IdSplitAdvancedScenario
            description: Script.description(itemObject)
            hasChild: Script.hasChild(itemObject)
            editable: true
            onDelegateClicked: {
                if (itemObject.objectId === ObjectInterface.IdSplitBasicScenario ||
                        itemObject.objectId === ObjectInterface.IdSplitAdvancedScenario)
                    column.loadColumn(mapping.getComponent(itemObject.objectId), itemObject.name, itemObject)
                else {
                    resetSelection()
                    itemObject.apply()
                }
            }
        }
        model: objectModel

        onCurrentPageChanged: column.closeChild()
    }
}
