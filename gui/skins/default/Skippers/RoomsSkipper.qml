import QtQuick 1.1
import BtObjects 1.0

Item {
    function pageSkip() {
        if (roomModel.count === 1) {
            return {"page": "Room.qml", "properties": {}}
        }
        return {"page": "", "properties": {}}
    }

    MediaModel {
        source: myHomeModels.rooms
        id: roomModel
    }
}
