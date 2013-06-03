import QtQuick 1.1
import BtObjects 1.0
import "js/array.js" as Script


/**
  \ingroup EnergyDataSystem

  \brief Translations for the EnergyDataSystem system.
  */
QtObject {
    // internal function to load values into the container
    function _init(container) {
        container['ENERGY_TYPE'] = []
        container['STOP_GO_STATUS'] = []

        // stop&go status translations
        container['STOP_GO_STATUS'][StopAndGo.Unknown] = qsTr("Unknown")
        container['STOP_GO_STATUS'][StopAndGo.Closed] = qsTr("Closed")
        container['STOP_GO_STATUS'][StopAndGo.Opened] = qsTr("Open")
        container['STOP_GO_STATUS'][StopAndGo.Blocked] = qsTr("Blocked")
        container['STOP_GO_STATUS'][StopAndGo.ShortCircuit] = qsTr("Short Circuit")
        container['STOP_GO_STATUS'][StopAndGo.GroundFail] = qsTr("Ground Fault")
        container['STOP_GO_STATUS'][StopAndGo.Overtension] = qsTr("Overvoltage")

        // "normal" strings
        container['ENERGY_TYPE']["Consumption Management"] = qsTr("Consumption Management")

        // EnergyType
        container['ENERGY_TYPE'][EnergyData.Electricity] = qsTr("Electricity")
        container['ENERGY_TYPE'][EnergyData.Water] = qsTr("Water")
        container['ENERGY_TYPE'][EnergyData.Gas] = qsTr("Gas")
        container['ENERGY_TYPE'][EnergyData.HotWater] = qsTr("Hot Water")
        container['ENERGY_TYPE'][EnergyData.Heat] = qsTr("Heat")
    }

    /**
      Retrieves the requested value from the local array.
      @param type:string context The translation context to distinguish between similar id.
      @param type:int id The id referring to the string to be translated.
      */
    function get(context, id) {
        if (Script.container.length === 0)
            _init(Script.container)

        return Script.container[context][id]
    }
}
