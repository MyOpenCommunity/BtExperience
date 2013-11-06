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
import "../../js/logging.js" as Log


MenuColumn {
    id: column

    onChildDestroyed: {
        itemList.currentIndex = -1
    }

    SystemsModel {id: systemsModel; systemId: Container.IdVideoDoorEntry }
    ObjectModel {
        id: intercomModel
        filters: [{"objectId": ObjectInterface.IdIntercom}]
    }

    ObjectModel {
        id: cctvModel
        filters: [{objectId: ObjectInterface.IdCCTV}]
    }

    ObjectModel {
        id: intercomPlaceModel
        containers: [systemsModel.systemUii]
        source: intercomModel.getObject(0).externalPlaces
    }

    ObjectModel {
        id: pagerModel
        containers: [systemsModel.systemUii]
        filters: [{objectId: ObjectInterface.IdPager}]
    }

    ObjectModel {
        id: cctvPlaceModel
        containers: [systemsModel.systemUii]
        source: cctvModel.getObject(0).externalPlaces
    }

    PaginatorList {
        id: itemList
        currentIndex: -1

        delegate: MenuItemDelegate {
            name: model.name
            hasChild: true
            onDelegateTouched: {
                var clickedItem = modelList.get(index)
                column.loadColumn(clickedItem.component, clickedItem.name)
            }
        }

        model: modelList
        onCurrentPageChanged: column.closeChild()
    }

    ListModel {
        id: modelList
        Component.onCompleted: {
            if (cctvPlaceModel.count > 0)
                modelList.append({"name": qsTr("video control"), "component": cctv})
            if (intercomPlaceModel.count > 0)
                modelList.append({"name": qsTr("intercom"), "component": intercom})
            if (pagerModel.count > 0)
                modelList.append({"name": qsTr("pager"), "component": pager})
        }
    }

    Component {
        id: cctv
        CCTV {}
    }

    Component {
        id: intercom
        InterCom {}
    }

    Component {
        id: pager
        Pager {}
    }
}
