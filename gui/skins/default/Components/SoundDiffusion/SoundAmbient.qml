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
import "../../js/logging.js" as Log
import Components 1.0
import "../../js/MenuItem.js" as Script

MenuColumn {
    id: column

    property alias amplifierNumber: itemList.elementsOnPage
    property alias showSourceControl: sourceLoader.visible

    Component {
        id: sourceControl
        SourceControl {}
    }

    onChildDestroyed: {
        itemList.currentIndex = -1
        privateProps.currentIndex = -1
    }

    ObjectModel {
        id: ambientModel
        filters: [{objectId: ObjectInterface.IdAmbientAmplifier}]
        containers: [column.dataModel.uii]
    }

    BtObjectsMapping { id: mapping }

    ObjectModel {
        id: objectModel
        filters: [{objectId: ObjectInterface.IdSoundAmplifierGroup},
            {objectId: ObjectInterface.IdSoundAmplifier},
            {objectId: ObjectInterface.IdPowerAmplifier}
        ]
        containers: [column.dataModel.uii]
        range: itemList.computePageRange(itemList.currentPage, itemList.elementsOnPage)
    }

    Column {
        MenuItem {
            id: sourceLoader
            property variant itemObject: column.dataModel.currentSource
            isSelected: privateProps.currentIndex === 1
            name: qsTr("source")
            description: itemObject === undefined ? "" : itemObject.name
            hasChild: true
            onTouched: {
                privateProps.currentIndex = 1
                itemList.currentIndex = -1
                column.loadColumn(sourceControl, qsTr("source"), column.dataModel)
            }
        }

        Column {
            id: ambientControl
            visible: ambientModel.count > 0
            property variant itemObject: ambientModel.getObject(0)

            VolumeGeneral {
                description: ambientControl.itemObject.name
                onMinusClicked: ambientControl.itemObject.volumeDown()
                onPlusClicked: ambientControl.itemObject.volumeUp()
            }

            ControlOnOff {
                onClicked: ambientControl.itemObject.setActive(newStatus)
            }
        }

        PaginatorList {
            id: itemList

            elementsOnPage: elementsOnMenuPage - 4
            delegate: MenuItemDelegate {
                itemObject: objectModel.getObject(index)
                status: Script.status(itemObject)
                hasChild: Script.hasChild(itemObject)
                editable: true
                onDelegateClicked: {
                    privateProps.currentIndex = -1
                    column.loadColumn(mapping.getComponent(itemObject.objectId), itemObject.name, itemObject);
                }
            }

            model: objectModel
            onCurrentPageChanged: column.closeChild()
        }
    }

    QtObject {
        id: privateProps
        property int currentIndex: -1
    }
}
