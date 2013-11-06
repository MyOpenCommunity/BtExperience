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

MenuColumn {
    id: column

    SystemsModel { id: linksModel; systemId: Container.IdMultimediaWebRadio; source: myHomeModels.mediaContainers }

    ObjectModel {
        id: radioModel
        source: myHomeModels.mediaLinks
        containers: [linksModel.systemUii]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    PaginatorList {
        id: paginator
        elementsOnPage: 8
        delegate: MenuItemDelegate {
            itemObject: radioModel.getObject(index)
            editable: true
            onDelegateClicked: column.dataModel.startPlay(radios(radioModel), index, radioModel.count)
        }

        model: radioModel
        onCurrentPageChanged: column.closeChild()
    }

    function radios(model) {
        var radios = []

        for (var i = 0; i < model.count; ++i)
            radios.push(model.getObject(i))

        return radios
    }
}
