import QtQuick 1.1
import BtObjects 1.0
import "../js/Systems.js" as Script


/**
  \ingroup Core

  \brief A component that implements page skipping functionality for energy system.

  This component contains logic to skip the intermediate energy system pages
  if only one line is defined.
  */
Item {
    // the family we are trying to show
    property variant family: null

    /**
      Checks if the to be loaded page has to be skipped or not.
      @return type:array An array containing the page and the properties to load if skipping is needed.
      */
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

