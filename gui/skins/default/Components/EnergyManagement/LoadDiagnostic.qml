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
import "../../js/MenuItem.js" as MenuItem


MenuColumn {
    id: element

    SystemsModel { id: systemsModel; systemId: Container.IdSupervision }

    ObjectModel {
        id: listModel

        source: myHomeModels.myHomeObjects
        containers: [systemsModel.systemUii]
        filters: [
            {objectId: ObjectInterface.IdLoadDiagnostic}
        ]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    onChildDestroyed: paginator.currentIndex = -1

    Column {
        PaginatorList {
            id: paginator

            currentIndex: -1
            onCurrentPageChanged: element.closeChild()
            delegate: MenuItemDelegate {
                clickable: false
                itemObject: listModel.getObject(index)
                status: MenuItem.status(itemObject)
                hasChild: MenuItem.hasChild(itemObject)
                description: MenuItem.description(itemObject)
                name: itemObject.name
                Component.onCompleted: itemObject.requestLoadStatus()
            }
            model: listModel
        }
    }
}
