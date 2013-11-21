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
import BtExperience 1.0
import Components 1.0

import "../../js/MediaItem.js" as Script

MenuColumn {
    id: column

    signal sourceSelected(variant object)

    SourceModel { id: sourceModel }

    property variant savedObject
    PaginatorList {
        id: paginator
        property bool okClicked: false

        elementsOnPage: 8
        model: sourceModel.model
        delegate: MenuItemDelegate {
            id: sourceDelegate
            property variant itemObject: sourceModel.model.getObject(index)
            enabled: Script.mediaItemEnabled(itemObject)
            selectOnClick: false
            name: itemObject.name
            onDelegateTouched: {
                if (itemObject.sourceType === SourceObject.Upnp &&
                        global.upnpStatus !== GlobalProperties.UpnpInactive &&
                        global.upnpStatus !== GlobalProperties.UpnpSoundDiffusion) {
                    column.savedObject = itemObject
                    pageObject.installPopup(upnpDialog)
                }
                else {
                    column.sourceSelected(itemObject)
                }
            }
        }
        onCurrentPageChanged: column.closeChild()
    }

    Connections {
        target: column.pageObject
        onPopupDismissed: {
            if (paginator.okClicked)
                column.sourceSelected(column.savedObject)
        }
    }

    Component {
        id: upnpDialog

        TextDialog {
            title: qsTr("Multimedia is playing")
            text: qsTr("To activate media server in sound diffusion you need to stop the source.Proceed?")
            function okClicked() {
                global.audioVideoPlayer.terminate()
                paginator.okClicked = true
            }
            function cancelClicked() {
                paginator.okClicked = false
            }
        }
    }
}
