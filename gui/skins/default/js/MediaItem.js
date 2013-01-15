// Requires:
// import BtObjects 1.0

function mediaItemEnabled(itemObject) {
    if (itemObject.mountPoint)
        return itemObject.mountPoint.mounted
    if (itemObject.sourceType === SourceObject.Upnp)
        return !global.upnpPlaying

    return true
}
