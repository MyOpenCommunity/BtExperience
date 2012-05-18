import QtQuick 1.1
import BtObjects 1.0

import "js/Stack.js" as Stack


QuickLink {
    id: favoriteItem

    page: ""
    bgImage: "images/profiles/webcam.png"
    text: "Camera #0"

    onClicked: {
        cctvModel.getObject(0).cameraOn(extPlaceModel.getObject(0).where)
    }

    FilterListModel {
        id: cctvModel
        filters: [{objectId: ObjectInterface.IdCCTV}]
    }

    FilterListModel {
        id: extPlaceModel
        source: cctvModel.getObject(0).externalPlaces
    }
}
