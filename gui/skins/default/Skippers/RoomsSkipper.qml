import QtQuick 1.1
import BtObjects 1.0

Item {
    function pageSkip() {
        if (roomModel.count === 1) {
            return {"page": "Room.qml", "properties": {room: roomModel.getObject(0), floorUii: floorsModel.getObject(0).uii}}
        }
        return {"page": "", "properties": {}}
    }

    MediaModel {
        id: floorsModel
        source: myHomeModels.floors
    }

    MediaModel {
        source: myHomeModels.rooms
        id: roomModel
    }
}
