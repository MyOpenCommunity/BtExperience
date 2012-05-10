// some helper functions for Row&Column items

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
        row.children[j].width = (t - (c - 1) * s) / c
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
        col.children[j].height = (t - (c - 1) * s) / c
    }
}
