import QtQuick 1.1
import BtObjects 1.0


/**
  \ingroup Core

  \brief A component that implements page skipping functionality for Rooms system.

  This component checks if only one room in only one floor is defined. If so,
  when opening rooms system, it skips directly to room page.
  */
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

    /**
      Checks if the to be loaded page has to be skipped or not.
      @return type:array An array containing the page and the properties to load if skipping is needed.
      */
    function pageSkip() {
        if (floorsModel.count ===1 && roomModel.count === 1)
            return {"page": "Room.qml", "properties": {room: roomModel.getObject(0), floorUii: floorsModel.getObject(0).uii}}

        return {"page": "", "properties": {}}
    }
}
