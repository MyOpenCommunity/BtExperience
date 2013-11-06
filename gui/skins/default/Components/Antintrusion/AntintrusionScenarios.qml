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

MenuColumn {
    id: column

    signal scenarioSelected(variant obj)

    onScenarioSelected: obj.apply()

    ObjectModel {
        id: scenariosModel
        source: column.dataModel
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    PaginatorList {
        id: paginator

        currentIndex: selectItem()

        function selectItem() {
            for (var i = 0; i < scenariosModel.count; i++) {
                if (scenariosModel.getObject(i).selected === true)
                    return i;
            }

            return -1
        }

        delegate: MenuItemDelegate {
            itemObject: scenariosModel.getObject(index)
            selectOnClick: false // we don't want to break the binding for currentIndex
            description: itemObject.description
            editable: true
            onDelegateClicked: column.scenarioSelected(itemObject)
        }

        model: scenariosModel
    }
}
