import QtQuick 1.1
import BtObjects 1.0
import "../js/Systems.js" as Script

Item {
    property variant family: null

    function pageSkip() {
        if (energiesCounters.count === 1) {
            return {"page": "EnergyDataGraph.qml", "properties": {"energyData": energiesCounters.getObject(0)}}
        }
        return {"page": "", "properties": {}}
    }

    ObjectModel {
        id: energiesCounters
        filters: [{objectId: ObjectInterface.IdEnergyData, objectKey: family.objectKey}]
    }
}

