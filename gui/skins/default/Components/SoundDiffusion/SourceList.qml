import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

import "../../js/MediaItem.js" as Script

MenuColumn {
    id: column

    signal sourceSelected(variant object)

    SystemsModel { id: multiModel; systemId: Container.IdSoundDiffusionMulti }
    SystemsModel { id: monoModel; systemId: Container.IdSoundDiffusionMono }

    SystemsModel { id: ipradioContainer; systemId: Container.IdMultimediaWebRadio; source: myHomeModels.mediaContainers }
    MediaModel {
        id: ipradioModel
        containers: [ipradioContainer.systemUii]
        source: myHomeModels.mediaLinks
    }

    ObjectModel {
        id: sourceModel
        containers: [multiModel.systemUii, monoModel.systemUii]
        filters: ipradioModel.count === 0 ? [{objectId: ObjectInterface.IdSoundSource}]:
                                            [{objectId: ObjectInterface.IdSoundSource}, {objectId: ObjectInterface.IdIpRadioSource}]
    }

    PaginatorList {
        id: paginator
        elementsOnPage: 8
        model: sourceModel
        delegate: MenuItem {
            id: sourceDelegate
            property variant itemObject: sourceModel.getObject(index)
            enabled: Script.mediaItemEnabled(itemObject)
            name: itemObject.name
            onClicked: column.sourceSelected(itemObject)
        }
        onCurrentPageChanged: column.closeChild()
    }
}
