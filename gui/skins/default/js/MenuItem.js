
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
        return false
    }
    return true
}
