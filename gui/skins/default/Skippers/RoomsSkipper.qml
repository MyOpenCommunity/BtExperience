import QtQuick 1.1
import BtObjects 1.0


Item {
    MediaModel {
        id: floorsModel
        source: myHomeModels.floors
    }

    MediaModel {
        source: myHomeModels.rooms
        id: roomModel
        containers: [floorsModel.getObject(0).uii] // assumes at least one floor always exists
    }

    function pageSkip() {
        if (roomModel.count === 1)
            return {"page": "Room.qml", "properties": {room: roomModel.getObject(0)}}

        return {"page": "", "properties": {}}
    }
}
