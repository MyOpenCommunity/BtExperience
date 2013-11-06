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
import "../../js/MenuItem.js" as Script

MenuColumn {
    id: element

    SystemsModel { id: systemsModel; systemId: Container.IdSupervision }

    ObjectModel {
        id: listModel
        source: myHomeModels.myHomeObjects
        containers: [systemsModel.systemUii]
        filters: [
            {objectId: ObjectInterface.IdStopAndGo},
            {objectId: ObjectInterface.IdStopAndGoPlus},
            {objectId: ObjectInterface.IdStopAndGoBTest}
        ]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    ObjectModel {
        id: loadDiagnosticModel
        source: myHomeModels.myHomeObjects
        containers: [systemsModel.systemUii]
        filters: [
            {objectId: ObjectInterface.IdLoadDiagnostic}
        ]
    }

    onChildDestroyed: {
        paginator.currentIndex = -1
        privateProps.currentIndex = -1
    }

    Column {
        MenuItem {
            id: loadDiagnostic
            name: qsTr("load diagnostic")
            isSelected: privateProps.currentIndex === 1
            hasChild: true
            visible: loadDiagnosticModel.count > 0
            onTouched: {
                paginator.currentIndex = -1
                if (privateProps.currentIndex !== 1)
                    privateProps.currentIndex = 1
                element.loadColumn(component, name)
            }

            Component {
                id: component
                LoadDiagnostic {}
            }
        }

        PaginatorList {
            id: paginator
            elementsOnPage: elementsOnMenuPage - 1
            currentIndex: -1
            onCurrentPageChanged: element.closeChild()
            delegate: MenuItemDelegate {
                itemObject: listModel.getObject(index)
                name: itemObject.name
                description: Script.description(itemObject)
                status: Script.status(itemObject)
                hasChild: Script.hasChild(itemObject)
                onDelegateTouched: {
                    privateProps.currentIndex = -1
                    element.loadColumn(mapping.getComponent(itemObject.objectId), name, itemObject)
                }
            }
            model: listModel
        }
    }

    QtObject {
        id: privateProps

        property int currentIndex: -1
    }

    BtObjectsMapping { id: mapping }
}
