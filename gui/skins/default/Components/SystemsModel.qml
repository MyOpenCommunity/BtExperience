import QtQuick 1.1
import BtObjects 1.0


MediaModel {
    id: objectModel

    property int systemId: -1
    property int systemUii

    onSystemIdChanged: {
        for (var i = 0; i < objectModel.count; ++i) {
            if (objectModel.getObject(i).containerId === systemId) {
                systemUii = objectModel.getObject(i).uii
                break
            }
        }
    }

    source: myHomeModels.systems
}

