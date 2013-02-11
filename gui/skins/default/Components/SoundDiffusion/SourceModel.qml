import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

Item {
    property alias model: sourceModel

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
}
