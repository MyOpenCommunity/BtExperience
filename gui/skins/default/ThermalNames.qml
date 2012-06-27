import QtQuick 1.1
import "js/array.js" as Script
import BtObjects 1.0


QtObject {
    // internal function to load values into the container
    function _init(container) {
        container['SEASON'] = []
        container['SEASON'][ThermalControlUnit.Summer] = qsTr("summer")
        container['SEASON'][ThermalControlUnit.Winter] = qsTr("winter")

        container['CENTRAL_STATUS'] = []
        container['CENTRAL_STATUS'][ThermalControlUnit.IdHoliday] = qsTr("holiday")
        container['CENTRAL_STATUS'][ThermalControlUnit.IdOff] = qsTr("off")
        container['CENTRAL_STATUS'][ThermalControlUnit.IdAntifreeze] = qsTr("antifreeze")
        container['CENTRAL_STATUS'][ThermalControlUnit.IdManual] = qsTr("manual")
        container['CENTRAL_STATUS'][ThermalControlUnit.IdTimedManual] = qsTr("timed manual")
        container['CENTRAL_STATUS'][ThermalControlUnit.IdWeeklyPrograms] = qsTr("weekly programs")
        container['CENTRAL_STATUS'][ThermalControlUnit.IdWorking] = qsTr("vacation")
        container['CENTRAL_STATUS'][ThermalControlUnit.IdScenarios] = qsTr("scenario")

        container['PROBE_STATUS'] = []
        container['PROBE_STATUS'][ThermalControlledProbe.Auto] = qsTr("auto")
        container['PROBE_STATUS'][ThermalControlledProbe.Antifreeze] = qsTr("antifreeze")
        container['PROBE_STATUS'][ThermalControlledProbe.Manual] = qsTr("manual")
        container['PROBE_STATUS'][ThermalControlledProbe.Off] = qsTr("off")
        container['PROBE_STATUS'][ThermalControlledProbe.Unknown] = qsTr("--")

        container['MODE'] = []
        container['MODE'][SplitProgram.ModeOff] = qsTr("Off")
        container['MODE'][SplitProgram.ModeWinter] = qsTr("Heating")
        container['MODE'][SplitProgram.ModeSummer] = qsTr("Cooling")
        container['MODE'][SplitProgram.ModeFan] = qsTr("Fan")
        container['MODE'][SplitProgram.ModeDehumidification] = qsTr("Dry")
        container['MODE'][SplitProgram.ModeAuto] = qsTr("Automatic")

        container['SPEED'] = []
        container['SPEED'][SplitProgram.SpeedAuto] = qsTr("Automatic")
        container['SPEED'][SplitProgram.SpeedMin] = qsTr("Low")
        container['SPEED'][SplitProgram.SpeedMed] = qsTr("Medium")
        container['SPEED'][SplitProgram.SpeedMax] = qsTr("High")
        container['SPEED'][SplitProgram.SpeedSilent] = qsTr("Silent")
        container['SPEED'][SplitProgram.SpeedInvalid] = qsTr("")

        container['SWING'] = []
        container['SWING'][SplitProgram.SwingOff] = qsTr("Off")
        container['SWING'][SplitProgram.SwingOn] = qsTr("On")
        container['SWING'][SplitProgram.SwingInvalid] = qsTr("")

        container['FANCOIL_SPEED'] = []
        container['FANCOIL_SPEED'][0] = ""
        container['FANCOIL_SPEED'][ThermalControlledProbeFancoil.FancoilMin] = qsTr("min")
        container['FANCOIL_SPEED'][ThermalControlledProbeFancoil.FancoilMed] = qsTr("med")
        container['FANCOIL_SPEED'][ThermalControlledProbeFancoil.FancoilMax] = qsTr("max")
        container['FANCOIL_SPEED'][ThermalControlledProbeFancoil.FancoilAuto] = qsTr("auto")
    }

    // retrieves the requested value from the local array
    function get(context, id) {
        if (Script.container.length === 0)
            _init(Script.container)

        return Script.container[context][id]
    }
}
