import QtQuick 1.1
import BtObjects 1.0
import "js/array.js" as Script

QtObject {
    // internal function to load values into the container
    function _init(container) {
        container[Container.IdScenarios] = qsTr("Scenarios")
        container[Container.IdLights] = qsTr("lighting")
        container[Container.IdAutomation] = qsTr("automation")
        container[Container.IdAirConditioning] = qsTr("temperature control")
        container[Container.IdLoadControl] = qsTr("Energy management")
        container[Container.IdSupervision] = qsTr("Energy management")
        container[Container.IdEnergyData] = qsTr("Energy management")
        container[Container.IdThermalRegulation] = qsTr("temperature control")
        container[Container.IdVideoDoorEntry] = qsTr("video door entry")
        container[Container.IdSoundDiffusionMulti] = qsTr("Sound System")
        container[Container.IdAntintrusion] = qsTr("Burglar alarm")
        container[Container.IdMessages] = qsTr("messages")
        container[Container.IdSoundDiffusionMono] = qsTr("Sound System")
    }

    /**
      Retrieves the requested value from the local array.
      @param type:int containerId The id of the container.
      */
    function get(containerId) {
        if (Script.container.length === 0)
            _init(Script.container)

        return Script.container[containerId]
    }
}
