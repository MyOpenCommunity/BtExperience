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
    }
    return ""
}

function hasChild(itemObject) {
    switch (itemObject.objectId) {
    case ObjectInterface.IdExternalPlace:
    case ObjectInterface.IdSurveillanceCamera:
    case ObjectInterface.IdSwitchboard:
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
