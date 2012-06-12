.pragma library

// Constants for Card*View
// These values are defined here since are needed in the delegates, other values
// (eg. spacing between delegates) are defined in the Views

// the first thing we need is a measure to base other computations; we choose
// the delegate width: changing it, everything else changes accordingly
var listDelegateWidth = 150
// NOTE: when changing listDelegateWidth check that delegates (completed with
// shadows) are completely visible because height is computed with respect to
// width

// not sure we need it
var gridDelegateWidth = 140

// some measures dependent on widths
var _gridCardHeight = gridDelegateWidth / 100 * 114
var _gridShadowHeight = gridDelegateWidth / 100 * 16
var gridDelegateHeight = _gridCardHeight + _gridShadowHeight


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
