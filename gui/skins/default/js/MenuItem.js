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
        return itemObject.active === true ? 1 : 0;
    }
    return -1
}

function description(itemObject) {
    var descr = ""

    switch (itemObject.objectId) {
    case ObjectInterface.IdThermalControlledProbe:
    case ObjectInterface.IdThermalControlledProbeFancoil:
        var localProbeStatus = itemObject.localProbeStatus
        var probeStatus = itemObject.probeStatus

        // show 'protection' or 'off'
        if (localProbeStatus === ThermalControlledProbe.Antifreeze ||
                localProbeStatus === ThermalControlledProbe.Off) {
            return pageObject.names.get('PROBE_STATUS', localProbeStatus)
        }
        else if (probeStatus === ThermalControlledProbe.Antifreeze ||
                 probeStatus === ThermalControlledProbe.Off) {
            return pageObject.names.get('PROBE_STATUS', probeStatus)
        }

        // no special state, show setpoint (if in manual) and local offset
        if (probeStatus === ThermalControlledProbe.Manual) {
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
    }
    return descr
}

function boxInfoState(itemObject) {
    switch (itemObject.objectId) {
    case ObjectInterface.IdDimmerFixed:
    case ObjectInterface.IdDimmer100Fixed:
    case ObjectInterface.IdDimmer100Custom:
        return "info"
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
