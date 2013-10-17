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
            text: qsTr("UPnP support is limited to only one active source. \
The UPnP source is busy in multimedia. Do you want to stop the multimedia \
source?")
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
