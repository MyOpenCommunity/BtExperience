// Requires:
// import BtObjects 1.0

function mediaItemEnabled(itemObject, restoredItem) {
    if (itemObject.mountPoint)
        return itemObject.mountPoint.mounted

    return true
}

function mediaItemMounted(itemObject) {
    if (itemObject.mountPoint)
        return itemObject.mountPoint.mounted

    return true
}
