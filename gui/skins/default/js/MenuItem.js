// Requires:
// import BtObjects 1.0
// pageObject with names

function status(itemObject) {
    switch (itemObject.objectId) {
    case ObjectInterface.IdLightFixedPP:
    case ObjectInterface.IdLightCustomPP:
    case ObjectInterface.IdDimmerFixedPP:
    case ObjectInterface.IdDimmer100FixedPP:
    case ObjectInterface.IdDimmer100CustomPP:
    case ObjectInterface.IdSoundAmplifier:
    case ObjectInterface.IdPowerAmplifier:
        return itemObject.active === true ? 1 : 0

    case ObjectInterface.IdLightFixedAMBGRGEN:
    case ObjectInterface.IdLightCustomAMBGRGEN:
    case ObjectInterface.IdDimmerFixedAMBGRGEN:
    case ObjectInterface.IdDimmer100FixedAMBGRGEN:
    case ObjectInterface.IdDimmer100CustomAMBGRGEN:
        return -1

    case ObjectInterface.IdMultiChannelSoundAmbient:
    case ObjectInterface.IdMonoChannelSoundAmbient:
        return itemObject.hasActiveAmplifier

    case ObjectInterface.IdAutomation2GEN:
    case ObjectInterface.IdAutomationGroup2:
    case ObjectInterface.IdAutomationVDE:
    case ObjectInterface.IdAutomationDoor:
    case ObjectInterface.IdAutomation3UpDown:
    case ObjectInterface.IdAutomation3UpDownSafe:
    case ObjectInterface.IdAutomation3OpenClose:
    case ObjectInterface.IdAutomation3OpenCloseSafe:
    case ObjectInterface.IdAutomationGroup3OpenClose:
    case ObjectInterface.IdAutomationGroup3UpDown:
        return -1

    case ObjectInterface.IdAutomation2Normal:
    case ObjectInterface.IdAutomation3:
    case ObjectInterface.IdAutomation3Safe:
    case ObjectInterface.IdAutomationGroup2:
    case ObjectInterface.IdAutomationGroup3:
        return itemObject.active === true ? 1 : 0

    case ObjectInterface.IdAlarmClock:
        return (itemObject.validityStatus !== AlarmClock.AlarmClockApplyResultOk) ? 3 : -1

    case ObjectInterface.IdLoadWithControlUnit:
    case ObjectInterface.IdLoadWithoutControlUnit:
        switch (itemObject.energyLoadStatus) {
        case EnergyLoadDiagnostic.EnergyLoadAbsent:
            return 0
        case EnergyLoadDiagnostic.EnergyLoadOk:
            return 1
        case EnergyLoadDiagnostic.EnergyLoadDisabled:
            return 4
        case EnergyLoadDiagnostic.EnergyLoadDetached:
            return 3
        }
        break

    case ObjectInterface.IdStopAndGo:
    case ObjectInterface.IdStopAndGoPlus:
    case ObjectInterface.IdStopAndGoBTest:
        switch (itemObject.status) {
        case StopAndGo.Closed:
            return 1
        case StopAndGo.Unknown:
            return 0
        default:
            return 3
        }

    case ObjectInterface.IdLoadDiagnostic:
        switch (itemObject.loadStatus) {
        case EnergyLoadDiagnostic.Unknown:
            return 0
        case EnergyLoadDiagnostic.Ok:
            return 1
        case EnergyLoadDiagnostic.Warning:
            return 2
        case EnergyLoadDiagnostic.Critical:
            return 3
        }
    }

    return -1
}

function description(itemObject) {
    var descr = ""

    switch (itemObject.objectId) {
    case ObjectInterface.IdThermalControlledProbe:
    case ObjectInterface.IdThermalControlledProbeFancoil:
        var probeStatus = itemObject.probeStatus
        var setPoint = itemObject.setpoint
        var localOffset = itemObject.localOffset

        // show 'protection' or 'off'
        if (probeStatus === ThermalControlledProbe.Antifreeze ||
                probeStatus === ThermalControlledProbe.Off) {
            return pageObject.names.get('PROBE_STATUS', probeStatus)
        }

        // no special state, show setpoint (if in manual) and local offset
        if (probeStatus === ThermalControlledProbe.Manual ||
                probeStatus === ThermalControlledProbe.Auto) {
            descr += (setPoint / 10).toFixed(1) + qsTr("°C")
        }
        if (!_isProbeOffsetZero(itemObject))
            descr += " " + _getOffsetRepresentation(localOffset)
        descr += " " + pageObject.names.get('PROBE_STATUS', probeStatus)
        break
    case ObjectInterface.IdThermalControlUnit99:
    case ObjectInterface.IdThermalControlUnit4:
        var currentModalityId = itemObject.currentModalityId

        if (currentModalityId !== undefined && currentModalityId >= 0)
            descr += pageObject.names.get('CENTRAL_STATUS', currentModalityId)
        break
    case ObjectInterface.IdAlarmClock:
        if (itemObject.validityStatus === AlarmClock.AlarmClockApplyResultNoAmplifier)
            descr = qsTr("No amplifier set")
        else if (itemObject.validityStatus === AlarmClock.AlarmClockApplyResultNoSource)
            descr = qsTr("No source set")
        else if (itemObject.validityStatus === AlarmClock.AlarmClockApplyResultNoName)
            descr = qsTr("No name set")
        break

    case ObjectInterface.IdLoadWithControlUnit:
    case ObjectInterface.IdLoadWithoutControlUnit:
        switch (itemObject.energyLoadStatus) {
        case EnergyLoadDiagnostic.EnergyLoadAbsent:
            descr = qsTr("")
            break
        case EnergyLoadDiagnostic.EnergyLoadOk:
            descr = qsTr("Control enabled")
            break
        case EnergyLoadDiagnostic.EnergyLoadDisabled:
            descr = qsTr("Control disabled")
            break
        case EnergyLoadDiagnostic.EnergyLoadDetached:
            descr = qsTr("Load detached")
            break
        }
        break

    case ObjectInterface.IdEnergyData:
        descr = itemObject.familyName
        break
    case ObjectInterface.IdLoadDiagnostic:
        switch (itemObject.loadStatus) {
        case EnergyLoadDiagnostic.Ok:
            descr = qsTr("Ok")
            break
        case EnergyLoadDiagnostic.Warning:
            descr = qsTr("Warning")
            break
        case EnergyLoadDiagnostic.Critical:
            descr = qsTr("Danger")
            break
        }
        break

    case ObjectInterface.IdStopAndGo:
    case ObjectInterface.IdStopAndGoPlus:
    case ObjectInterface.IdStopAndGoBtest:
        switch (itemObject.status) {
        case StopAndGo.Closed:
            descr = qsTr("Closed")
            break
        case StopAndGo.Opened:
            descr = qsTr("Open")
            break
        case StopAndGo.Blocked:
            descr = qsTr("Open - Block")
            break
        case StopAndGo.ShortCircuit:
            descr = qsTr("Open - Short Circuit")
            break
        case StopAndGo.GroundFail:
            descr = qsTr("Open - Earth Fault")
            break
        case StopAndGo.Overtension:
            descr = qsTr("Open - Over Current")
            break
        default:
            descr = qsTr("Unknown")
        }
        break
    case ObjectInterface.IdSplitBasicScenario:
    case ObjectInterface.IdSplitAdvancedScenario:
        if (itemObject.temperatureEnabled) {
            if (itemObject.temperatureIsValid)
                descr = (itemObject.temperature / 10).toFixed(1) + " °C"
            else
                descr = "---"
        }
        break
    }

    return descr
}

function boxInfoState(itemObject) {
    switch (itemObject.objectId) {
    case ObjectInterface.IdDimmerFixedPP:
    case ObjectInterface.IdDimmer100FixedPP:
    case ObjectInterface.IdDimmer100CustomPP:
        return "info"
    case ObjectInterface.IdDimmerFixedAMBGRGEN:
    case ObjectInterface.IdDimmer100FixedAMBGRGEN:
    case ObjectInterface.IdDimmer100CustomAMBGRGEN:
        return ""
    case ObjectInterface.IdThermalControlledProbe:
    case ObjectInterface.IdThermalControlledProbeFancoil:
    case ObjectInterface.IdThermalExternalProbe:
    case ObjectInterface.IdThermalNonControlledProbe:
        return "info"
    case ObjectInterface.IdThermalControlUnit99:
    case ObjectInterface.IdThermalControlUnit4:
        if (itemObject.currentModalityId === ThermalControlUnit.IdManual ||
                itemObject.currentModalityId === ThermalControlUnit.IdTimedManual)
            return "info"
        break
    }
    return ""
}

function boxInfoText(itemObject) {
    switch (itemObject.objectId) {
    case ObjectInterface.IdDimmerFixedPP:
    case ObjectInterface.IdDimmer100FixedPP:
    case ObjectInterface.IdDimmer100CustomPP:
        if (itemObject.active)
            return itemObject.percentage + "%"
        else
            return "-"
    case ObjectInterface.IdDimmerFixedAMBGRGEN:
    case ObjectInterface.IdDimmer100FixedAMBGRGEN:
    case ObjectInterface.IdDimmer100CustomAMBGRGEN:
        return ""
    case ObjectInterface.IdThermalControlledProbe:
    case ObjectInterface.IdThermalControlledProbeFancoil:
    case ObjectInterface.IdThermalExternalProbe:
    case ObjectInterface.IdThermalNonControlledProbe:
        return (itemObject.temperature / 10).toFixed(1) + "°C"
    case ObjectInterface.IdThermalControlUnit99:
    case ObjectInterface.IdThermalControlUnit4:
        if (itemObject.currentModalityId === ThermalControlUnit.IdManual ||
                itemObject.currentModalityId === ThermalControlUnit.IdTimedManual)
            return (itemObject.currentModality.temperature / 10).toFixed(1) + "°C"
        break
    }
    return ""
}

function hasChild(itemObject) {
    switch (itemObject.objectId) {
    case ObjectInterface.IdExternalPlace:
    case ObjectInterface.IdSurveillanceCamera:
    case ObjectInterface.IdSwitchboard:
    case ObjectInterface.IdEnergyData:
    case ObjectInterface.IdSplitBasicGenericCommandGroup:
    case ObjectInterface.IdSplitAdvancedGenericCommandGroup:
    case ObjectInterface.IdLoadDiagnostic:
        return false
    }
    return true
}

function _isProbeOffsetZero(itemObject) {
    return (itemObject.localOffset === 0)
}

function _getOffsetRepresentation(offset) {
    // we need to output a '+' sign for positive values
    var r = offset > 0 ? "+" : ""
    r += offset
    return r
}
