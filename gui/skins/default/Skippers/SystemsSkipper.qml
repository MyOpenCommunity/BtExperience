import QtQuick 1.1
import BtObjects 1.0
import "../js/Systems.js" as Script

Item {
    function pageSkip() {
        if (systemsModel.count === 1) {
            return {"page": Script.getTarget(systemsModel.getObject(0).containerId), "properties": {}}
        }
        return {"page": "", "properties": {}}
    }

    ObjectModel {
        id: systemsModel
        source: myHomeModels.systems
    }
}
