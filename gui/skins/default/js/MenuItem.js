// Requires:
// import BtObjects 1.0
// pageObject with names

function status(itemObject) {
    switch (itemObject.objectId) {
    case ObjectInterface.IdLightFixed:
    case ObjectInterface.IdLightCustom:
    case ObjectInterface.IdDimmerFixed:
    case ObjectInterface.IdDimmer100Fixed:
    case ObjectInterface.IdDimmer100Custom:
    case ObjectInterface.IdSoundAmplifier:
    case ObjectInterface.IdPowerAmplifier:
        return itemObject.active === true ? 1 : 0

    case ObjectInterface.IdMultiChannelSoundAmbient:
    case ObjectInterface.IdMonoChannelSoundAmbient:
        return itemObject.hasActiveAmplifier

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

    case ObjectInterface.IdAutomation2:
    case ObjectInterface.IdAutomation3:
    case ObjectInterface.IdAutomation3Safe:
    case ObjectInterface.IdAutomationContact:
    case ObjectInterface.IdAutomationGroup2:
    case ObjectInterface.IdAutomationGroup3:
        return itemObject.active === true ? 1 : 0

    case ObjectInterface.IdAlarmClock:
        return (itemObject.validityStatus !== AlarmClock.AlarmClockApplyResultOk) ? 3 : -1

    case ObjectInterface.IdLoadWithControlUnit:
        if (itemObject.loadEnabled && itemObject.loadForced)
            return 3
        else if (itemObject.loadEnabled && !itemObject.loadForced)
            return 1
        else
            return 0

    case ObjectInterface.IdStopAndGo:
    case ObjectInterface.IdStopAndGoPlus:
    case ObjectInterface.IdStopAndGoBtest:
        switch (itemObject.status) {
        case StopAndGo.Closed:
            return 1
        case StopAndGo.Unknown:
            return 0
        default:
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
        // show 'protection' or 'off'
        if (probeStatus === ThermalControlledProbe.Antifreeze ||
                probeStatus === ThermalControlledProbe.Off) {
            return pageObject.names.get('PROBE_STATUS', probeStatus)
        }

        // no special state, show setpoint (if in manual) and local offset
        if (probeStatus === ThermalControlledProbe.Manual ||
                probeStatus === ThermalControlledProbe.Auto) {
            descr += (itemObject.setpoint / 10).toFixed(1) + qsTr("°C")
        }
        if (!_isProbeOffsetZero(itemObject))
            descr += " " + _getOffsetRepresentation(itemObject.localOffset)
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
        if (itemObject.hasControlUnit) {
            if (itemObject.loadEnabled && itemObject.loadForced)
                descr =  qsTr("Forced")
            else if (itemObject.consumption > 0)
                descr = itemObject.consumption + " " + itemObject.currentUnit
        }
        break
    case ObjectInterface.IdLoadWithoutControlUnit:
        if (itemObject.consumption > 0)
            descr = itemObject.consumption + " " + itemObject.currentUnit
        break
    case ObjectInterface.IdEnergyData:
        descr = itemObject.familyName
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
        case StopAndGo.Locked:
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
    }

    return descr
}

function boxInfoState(itemObject) {
    switch (itemObject.objectId) {
    case ObjectInterface.IdDimmerFixed:
    case ObjectInterface.IdDimmer100Fixed:
    case ObjectInterface.IdDimmer100Custom:
        return "info"
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
    case ObjectInterface.IdLoadWithControlUnit:
        if (itemObject.hasControlUnit) {
            if (itemObject.loadEnabled && itemObject.loadForced)
                return "warning"
            return "info"
        }
    }
    return ""
}

function boxInfoText(itemObject) {
    switch (itemObject.objectId) {
    case ObjectInterface.IdDimmerFixed:
    case ObjectInterface.IdDimmer100Fixed:
    case ObjectInterface.IdDimmer100Custom:
        if (itemObject.active)
            return itemObject.percentage + "%"
        else
            return "-"
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
    case ObjectInterface.IdLoadWithControlUnit:
    case ObjectInterface.IdLoadWithoutControlUnit:
        if (itemObject.hasControlUnit) {
            if (itemObject.loadEnabled)
                return "1"
            return "0"
        }
    }
    return ""
}

function hasChild(itemObject) {
    switch (itemObject.objectId) {
    case ObjectInterface.IdExternalPlace:
    case ObjectInterface.IdSurveillanceCamera:
    case ObjectInterface.IdSwitchboard:
    case ObjectInterface.IdEnergyData:
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
