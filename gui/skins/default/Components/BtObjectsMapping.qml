import QtQuick 1.1
import BtObjects 1.0


/**
  * It was not possible to use Components.
  * In case of circular imports, the createObject function hangs forever.
  * Reverting to file names (at least for now).
  * Another possibility is to use new <<Component>>() in Javascript code, but
  * it is not clear if it is a bug or a feature, so we leave apart at the moment.
  */
QtObject {
    function getComponent(objectId) {
        //console.log("getComponent(): " + objectId)
        switch (objectId) {
        case ObjectInterface.IdLightCustom:
            return Qt.createComponent("Lighting/Light.qml")
        case ObjectInterface.IdLightFixed:
            return Qt.createComponent("Lighting/Light.qml")
        case ObjectInterface.IdDimmerFixed:
            return Qt.createComponent("Lighting/Dimmer.qml")
        case ObjectInterface.IdDimmer100Custom:
            return Qt.createComponent("Lighting/Dimmer.qml")
        case ObjectInterface.IdDimmer100Fixed:
            return Qt.createComponent("Lighting/Dimmer.qml")
        case ObjectInterface.IdLightGroup:
        case ObjectInterface.IdDimmerGroup:
        case ObjectInterface.IdDimmer100Group:
            return Qt.createComponent("Lighting/LightGroup.qml")
        case ObjectInterface.IdAutomation2:
        case ObjectInterface.IdAutomationContact:
            return Qt.createComponent("Automation/Automation2.qml")
        case ObjectInterface.IdAutomation3:
            return Qt.createComponent("Automation/Automation3.qml")
        case ObjectInterface.IdAutomationVDE:
        case ObjectInterface.IdAutomationDoor:
            return Qt.createComponent("Automation/Automation1.qml")
        //case ObjectInterface.IdAutomationCommand2: //!< Automation AMB, GEN, GR
        //case ObjectInterface.IdAutomationCommand3: //!< Automation 3-states AMB, GEN, GR
        case ObjectInterface.IdAutomationGroup2:
            return Qt.createComponent("Automation/AutomationGroup2.qml")
        case ObjectInterface.IdAutomationGroup3:
            return Qt.createComponent("Automation/AutomationGroup3.qml")
        case ObjectInterface.IdThermalControlUnit4:
            return Qt.createComponent("ThermalRegulation/ThermalControlUnit.qml")
        case ObjectInterface.IdThermalControlUnit99:
            return Qt.createComponent("ThermalRegulation/ThermalControlUnit.qml")
        case ObjectInterface.IdThermalControlledProbe:
            return Qt.createComponent("ThermalRegulation/ThermalControlledProbe.qml")
        case ObjectInterface.IdThermalControlledProbeFancoil:
            return Qt.createComponent("ThermalRegulation/ThermalControlledProbe.qml")
        case ObjectInterface.IdThermalNonControlledProbe:
            return Qt.createComponent("ThermalRegulation/ThermalNotControlledProbe.qml")
        case ObjectInterface.IdThermalExternalProbe:
            return Qt.createComponent("ThermalRegulation/ThermalNotControlledProbe.qml")
        case ObjectInterface.IdHardwareSettings:
            return Qt.createComponent("Settings/Brightness.qml")
        case ObjectInterface.IdMultiChannelGeneralAmbient:
            return Qt.createComponent("SoundDiffusion/GeneralAmbient.qml")
        case ObjectInterface.IdMultiChannelSoundAmbient:
        case ObjectInterface.IdMonoChannelSoundAmbient:
            return Qt.createComponent("SoundDiffusion/SoundAmbient.qml")
        case ObjectInterface.IdMultiChannelSpecialAmbient:
            return Qt.createComponent("SoundDiffusion/SpecialAmbient.qml")
        case ObjectInterface.IdSoundAmplifier:
            return Qt.createComponent("SoundDiffusion/Amplifier.qml")
        case ObjectInterface.IdPowerAmplifier:
            return Qt.createComponent("SoundDiffusion/PowerAmplifier.qml")
        case ObjectInterface.IdSoundAmplifierGroup:
            return Qt.createComponent("SoundDiffusion/AmplifierGeneral.qml")
        case ObjectInterface.IdSplitBasicScenario:
            return Qt.createComponent("ThermalRegulation/BasicSplit.qml")
        case ObjectInterface.IdSplitAdvancedScenario:
            return Qt.createComponent("ThermalRegulation/AdvancedSplit.qml")
        case ObjectInterface.IdSimpleScenario:
        case ObjectInterface.IdScenarioModule:
            return Qt.createComponent("Scenarios/SimpleScenario.qml")
        case ObjectInterface.IdScheduledScenario:
            return Qt.createComponent("Scenarios/ScheduledScenario.qml")
        case ObjectInterface.IdAdvancedScenario:
            return Qt.createComponent("Scenarios/AdvancedScenario.qml")
        case ObjectInterface.IdExternalIntercom:
        case ObjectInterface.IdInternalIntercom:
            return Qt.createComponent("VideoDoorEntry/Talk.qml")
        default:
            console.log("getComponent(): Unknown object id: " + objectId)
            return ""
        }
    }
}
