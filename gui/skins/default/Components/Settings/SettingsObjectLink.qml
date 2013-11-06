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

    property int uii
    property int index

    MediaModel {
        id: objectLinksModel
        source: myHomeModels.objectLinks
        containers: [uii]
    }

    Column {
        MenuItem {
            name: qsTr("Rename")
            onTouched: {
                pageObject.installPopup(quicklinkEditComponent, {"item": objectLinksModel.getObject(index).btObject})
            }
        }

        MenuItem {
            name: qsTr("Delete")
            onTouched: pageObject.installPopup(deleteConfirmDialog)
        }
    }

    Connections {
        target: pageObject.popupLoader.item
        onClosePopup: column.closeColumn()
    }

    Component {
        id: quicklinkEditComponent
        FavoriteEditPopup {
            property variant item

            title: qsTr("Change object name")
            topInputLabel: qsTr("New Name:")
            topInputText: objectLinksModel.getObject(index).btObject.name
            bottomVisible: false

            function okClicked() {
                item.name = topInputText
            }
        }
    }

    Component {
        id: deleteConfirmDialog
        TextDialog {
            function okClicked() {
                objectLinksModel.remove(objectLinksModel.getObject(index))
            }

            title: qsTr("Confirm deletion")
            text: qsTr("Are you sure to delete the selected object?")
        }
    }
}
