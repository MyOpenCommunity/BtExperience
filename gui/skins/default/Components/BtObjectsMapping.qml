import QtQuick 1.1
import BtObjects 1.0

import Components.Lighting 1.0
import Components.Scenarios 1.0
import Components.Settings 1.0
import Components.SoundDiffusion 1.0
import Components.ThermalRegulation 1.0


/**
  * This module is needed because we cannot define Components inside a model.
  * Here we define an Item and put all components in it. We have moved
  * the getComponent function here, too. Now, it is possible to use
  * FilterListModel directly. If you need the getComponent function you can
  * instantiate this module and call the function on the instance of it.
  */
Item {

    Component {
        id: basicSplit
        BasicSplit {}
    }

    Component {
        id: light
        Light {}
    }

    Component {
        id: dimmer
        Dimmer {}
    }

    Component {
        id: thermalControlUnit
        ThermalControlUnit {}
    }

    Component {
        id: simpleScenario
        SimpleScenario {}
    }

    Component {
        id: advancedSplit
        AdvancedSplit {}
    }

    Component {
        id: amplifierGeneral
        AmplifierGeneral {}
    }

    Component {
        id: powerAmplifier
        PowerAmplifier {}
    }

    Component {
        id: amplifier
        Amplifier {}
    }

    Component {
        id: soundAmbient
        SoundAmbient {}
    }

    Component {
        id: generalAmbient
        GeneralAmbient {}
    }

    Component {
        id: thermalControlledProbe
        ThermalControlledProbe {}
    }

    Component {
        id: brightness
        Brightness {}
    }

    function getComponent(objectId) {
        switch (objectId) {
        case ObjectInterface.IdLight:
            return light
        case ObjectInterface.IdDimmer:
            return dimmer
        case ObjectInterface.IdThermalControlUnit99:
            return thermalControlUnit
        case ObjectInterface.IdThermalControlledProbe:
            return thermalControlledProbe
        case ObjectInterface.IdHardwareSettings:
            return brightness
        case ObjectInterface.IdMultiChannelGeneralAmbient:
            return generalAmbient
        case ObjectInterface.IdMultiChannelSoundAmbient:
            return soundAmbient
        case ObjectInterface.IdMonoChannelSoundAmbient:
            return soundAmbient
        case ObjectInterface.IdSoundAmplifier:
            return amplifier
        case ObjectInterface.IdPowerAmplifier:
            return powerAmplifier
        case ObjectInterface.IdSoundAmplifierGeneral:
            return amplifierGeneral
        case ObjectInterface.IdSplitBasicScenario:
            return basicSplit
        case ObjectInterface.IdSplitAdvancedScenario:
            return advancedSplit
        case ObjectInterface.IdSimpleScenario:
            return simpleScenario
        case ObjectInterface.IdScenarioModule:
            return simpleScenario
        default:
            console.log("getComponent(): Unknown object id: " + objectId)
            return ""
        }
    }
}
