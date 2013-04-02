import QtQuick 1.1
import BtObjects 1.0
import "../js/Systems.js" as Script


/**
  \ingroup Core

  \brief A component that implements page skipping functionality.

  This component contains logic to skip the main systems page if only one
  system is defined. It navigates directly to the only system page.
  */
Item {
    /**
      Checks if the to be loaded page has to be skipped or not.
      @return type:array An array containing the page and the properties to load if skipping is needed.
      */
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

    Component.onCompleted: systemsModel.containers = Script.systemsModelContainers(systemsModel)
}
