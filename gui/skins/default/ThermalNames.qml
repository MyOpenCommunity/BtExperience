import QtQuick 1.1
import "js/array.js" as Script
import BtObjects 1.0

QtObject {
    function initNames() {
        Script.container['SEASON'] = []
        Script.container['SEASON'][ThermalControlUnit99Zones.Summer] = qsTr("summer")
        Script.container['SEASON'][ThermalControlUnit99Zones.Winter] = qsTr("winter")

        Script.container['PROBE_STATUS'] = []
        Script.container['PROBE_STATUS'][ThermalControlledProbe.Auto] = qsTr("auto")
        Script.container['PROBE_STATUS'][ThermalControlledProbe.Antifreeze] = qsTr("antifreeze")
        Script.container['PROBE_STATUS'][ThermalControlledProbe.Manual] = qsTr("manual")
        Script.container['PROBE_STATUS'][ThermalControlledProbe.Off] = qsTr("off")
        Script.container['PROBE_STATUS'][ThermalControlledProbe.Unknown] = qsTr("--")

        Script.container['BASIC_SPLIT'] = []
        Script.container['BASIC_SPLIT'][true] = qsTr("Enable")
        Script.container['BASIC_SPLIT'][false] = qsTr("Disable")

        Script.container['MODE'] = []
        Script.container['MODE'][SplitAdvancedScenario.ModeOff] = qsTr("Off")
        Script.container['MODE'][SplitAdvancedScenario.ModeWinter] = qsTr("Heating")
        Script.container['MODE'][SplitAdvancedScenario.ModeSummer] = qsTr("Cooling")
        Script.container['MODE'][SplitAdvancedScenario.ModeFan] = qsTr("Fan")
        Script.container['MODE'][SplitAdvancedScenario.ModeDehumidification] = qsTr("Dry")
        Script.container['MODE'][SplitAdvancedScenario.ModeAuto] = qsTr("Automatic")

        Script.container['SPEED'] = []
        Script.container['SPEED'][SplitAdvancedScenario.SpeedAuto] = qsTr("Automatic")
        Script.container['SPEED'][SplitAdvancedScenario.SpeedMin] = qsTr("Low")
        Script.container['SPEED'][SplitAdvancedScenario.SpeedMed] = qsTr("Medium")
        Script.container['SPEED'][SplitAdvancedScenario.SpeedMax] = qsTr("High")
        Script.container['SPEED'][SplitAdvancedScenario.SpeedSilent] = qsTr("Silent")
        Script.container['SPEED'][SplitAdvancedScenario.SpeedInvalid] = qsTr("")

        Script.container['SWING'] = []
        Script.container['SWING'][SplitAdvancedScenario.SwingOff] = qsTr("Off")
        Script.container['SWING'][SplitAdvancedScenario.SwingOn] = qsTr("On")
        Script.container['SWING'][SplitAdvancedScenario.SwingInvalid] = qsTr("")
    }

    function get(context, id) {
        if (Script.container.length === 0)
            initNames()

        return Script.container[context][id]
    }
}
