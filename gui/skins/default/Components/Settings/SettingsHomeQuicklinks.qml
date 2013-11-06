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
import "../../js/Stack.js" as Stack


MenuColumn {
    id: column

    ObjectModel {
        id: quicklinksModel
        source: myHomeModels.mediaLinks
        containers: [myHomeModels.homepageLinks.uii]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    onChildDestroyed: {
        paginator.currentIndex = -1
    }

    Component {
        id: renameDeleteItem
        SettingsHomeDelete {}
    }

    Column {
        MenuItem {
            name: qsTr("Add Quicklink")
            enabled: quicklinksModel.count < 7
            onTouched: {
                column.closeChild()
                Stack.pushPage("AddQuicklink.qml", {"homeCustomization": true})
            }
        }

        PaginatorList {
            id: paginator
            currentIndex: -1
            onCurrentPageChanged: column.closeChild()
            elementsOnPage: elementsOnMenuPage - 1
            delegate: MenuItemDelegate {
                itemObject: quicklinksModel.getObject(index)
                name: itemObject.name
                hasChild: true
                editable: true
                onDelegateClicked: column.loadColumn(renameDeleteItem, name, itemObject)
            }
            model: quicklinksModel
        }
    }
}
