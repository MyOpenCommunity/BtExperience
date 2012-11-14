import QtQuick 1.1
import BtObjects 1.0


QuickLink {
    id: favoriteItem

    page: ""
    imageSource: "../images/profiles/webcam.jpg"

    onClicked: {
        cctvModel.getObject(0).cameraOn(itemObject.btObject)
    }

    ObjectModel {
        id: cctvModel
        filters: [{objectId: ObjectInterface.IdCCTV}]
    }
}
