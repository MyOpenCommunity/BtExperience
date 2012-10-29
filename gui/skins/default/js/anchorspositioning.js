.pragma library

function computeAnchors(referredObject, editColumn) {
    // function to compute and set anchors considering the referredObject
    // position and the reference point

    // first of all, resets everything
    editColumn.anchors.top = undefined
    editColumn.anchors.bottom = undefined
    editColumn.anchors.left = undefined
    editColumn.anchors.right = undefined
    editColumn.anchors.leftMargin = 0
    editColumn.anchors.rightMargin = 0

    // checks if ref point is defined, if not default to top right
    if ((referredObject.refX === -1) || (referredObject.refY === -1)) {
        editColumn.anchors.top = referredObject.top
        editColumn.anchors.bottom = undefined
        editColumn.anchors.left = referredObject.right
        editColumn.anchors.right = undefined
        editColumn.anchors.leftMargin = 1
        editColumn.anchors.rightMargin = 0
        return
    }

    // referredObject.refX, referredObject.refY are absolute coordinates, so converts x, y to absolute ones
    var mov_cx = referredObject.mapToItem(null, 0, 0).x + 0.5 * referredObject.width
    var mov_cy = referredObject.mapToItem(null, 0, 0).y + 0.5 * referredObject.height

    // computes delta wrt the ref point
    var px = mov_cx - referredObject.refX
    var py = mov_cy - referredObject.refY

    // analyzes signs and sets the right anchorings
    if (px >= 0 && py >= 0) {
        // bottom left
        editColumn.anchors.top = undefined
        editColumn.anchors.bottom = referredObject.bottom
        editColumn.anchors.left = undefined
        editColumn.anchors.right = referredObject.left
        editColumn.anchors.leftMargin = 0
        editColumn.anchors.rightMargin = 1
        return
    }
    else if (px >= 0 && py <= 0) {
        // top left
        editColumn.anchors.top = referredObject.top
        editColumn.anchors.bottom = undefined
        editColumn.anchors.left = undefined
        editColumn.anchors.right = referredObject.left
        editColumn.anchors.leftMargin = 0
        editColumn.anchors.rightMargin = 1
        return
    }
    else if (px <= 0 && py >= 0) {
        // bottom right
        editColumn.anchors.top = undefined
        editColumn.anchors.bottom = referredObject.bottom
        editColumn.anchors.left = referredObject.right
        editColumn.anchors.right = undefined
        editColumn.anchors.leftMargin = 1
        editColumn.anchors.rightMargin = 0
        return
    }
    else {
        // top right
        editColumn.anchors.top = referredObject.top
        editColumn.anchors.bottom = undefined
        editColumn.anchors.left = referredObject.right
        editColumn.anchors.right = undefined
        editColumn.anchors.leftMargin = 1
        editColumn.anchors.rightMargin = 0
    }
}

