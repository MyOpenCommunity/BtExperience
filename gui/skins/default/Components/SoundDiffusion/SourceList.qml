import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

import "../../js/MediaItem.js" as Script

MenuColumn {
    id: column

    signal sourceSelected(variant object)

    SourceModel { id: sourceModel }

    PaginatorList {
        id: paginator
        elementsOnPage: 8
        model: sourceModel.model
        delegate: MenuItemDelegate {
            id: sourceDelegate
            property variant itemObject: sourceModel.model.getObject(index)
            enabled: Script.mediaItemEnabled(itemObject)
            selectOnClick: false
            name: itemObject.name
            onDelegateTouched: {
                if (itemObject.sourceType === SourceObject.Upnp && global.upnpPlaying) {
                    pageObject.installPopup(upnpDialog)
                }
                else {
                    column.sourceSelected(itemObject)
                }
            }
        }
        onCurrentPageChanged: column.closeChild()
    }

    Component {
        id: upnpDialog

        TextDialog {
            title: qsTr("UPnP is playing")
            text: qsTr("UPnP support is limited to only one active source and \
there's already an active source. Please stop the other player before \
continuing.")
            cancelVisible: false
        }
    }
}
