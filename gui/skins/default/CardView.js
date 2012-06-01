.pragma library

// Constants for Card*View
// These values are defined here since are needed in the delegates, other values
// (eg. spacing between delegates) are defined in the Views

// image + shadow below
var gridDelegateHeight = 140 + 22
var gridDelegateWidth = 140
var listDelegateWidth = 175

function visibleColumns(fullWidth, delegateWidth, horizontalSpacing, rows, modelCount) {
    var elementColumns = Math.ceil(modelCount / rows)
    // compute the number of visible elements
    var numColumns = Math.min(elementColumns, Math.floor(fullWidth / delegateWidth))
    // take delegate spacing into account (spacing is only between delegates)
    var spacingWidth = (numColumns - 1) * horizontalSpacing
    if (fullWidth - numColumns * delegateWidth > spacingWidth)
        return numColumns
    else
        return numColumns - 1
}
