// some helper functions for Row&Column items

var max_width = 150
var max_height = 300

// expands all items contained in the Row to occupy all available space
function updateRowChildren(row) {
    var l = row.children.length
    var c = l // real count of elements (repeaters skipped)
    var t = row.width
    var s = row.spacing

    for(var i = 0; i < l; ++i)
        if (row.children[i].objectName === 'repeater')
            --c

    for(var j = 0; j < l; ++j) {
        if (row.children[j].objectName === 'repeater')
            continue
        row.children[j].width = Math.min((t - (c - 1) * s) / c, max_width)
    }
}

// expands all items contained in the Column to occupy all available space
function updateColumnChildren(col) {
    var l = col.children.length
    var c = l // real count of elements (repeaters skipped)
    var t = col.height
    var s = col.spacing

    for(var i = 0; i < l; ++i)
        if (col.children[i].objectName === 'repeater')
            --c

    for(var j = 0; j < l; ++j) {
        if (col.children[j].objectName === 'repeater')
            continue
        col.children[j].height = Math.min((t - (c - 1) * s) / c, max_height)
    }
}
