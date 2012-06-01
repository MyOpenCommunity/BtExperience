import QtQuick 1.1
import BtObjects 1.0

import "js/Stack.js" as Stack


QuickLink {
    id: favoriteItem

    page: ""
    bgImage: "images/profiles/webcam.png"

    onClicked: {
        cctvModel.getObject(0).cameraOn(address)
    }

    FilterListModel {
        id: cctvModel
        filters: [{objectId: ObjectInterface.IdCCTV}]
    }
}
