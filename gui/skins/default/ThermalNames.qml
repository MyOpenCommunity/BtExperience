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

        Script.container['MODE'] = []
        Script.container['MODE'][SplitProgram.ModeOff] = qsTr("Off")
        Script.container['MODE'][SplitProgram.ModeWinter] = qsTr("Heating")
        Script.container['MODE'][SplitProgram.ModeSummer] = qsTr("Cooling")
        Script.container['MODE'][SplitProgram.ModeFan] = qsTr("Fan")
        Script.container['MODE'][SplitProgram.ModeDehumidification] = qsTr("Dry")
        Script.container['MODE'][SplitProgram.ModeAuto] = qsTr("Automatic")

        Script.container['SPEED'] = []
        Script.container['SPEED'][SplitProgram.SpeedAuto] = qsTr("Automatic")
        Script.container['SPEED'][SplitProgram.SpeedMin] = qsTr("Low")
        Script.container['SPEED'][SplitProgram.SpeedMed] = qsTr("Medium")
        Script.container['SPEED'][SplitProgram.SpeedMax] = qsTr("High")
        Script.container['SPEED'][SplitProgram.SpeedSilent] = qsTr("Silent")
        Script.container['SPEED'][SplitProgram.SpeedInvalid] = qsTr("")

        Script.container['SWING'] = []
        Script.container['SWING'][SplitProgram.SwingOff] = qsTr("Off")
        Script.container['SWING'][SplitProgram.SwingOn] = qsTr("On")
        Script.container['SWING'][SplitProgram.SwingInvalid] = qsTr("")
    }

    function get(context, id) {
        if (Script.container.length === 0)
            initNames()

        return Script.container[context][id]
    }
}
