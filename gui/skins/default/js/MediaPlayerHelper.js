.pragma library

function _initPlayer(mediaPlayer, model, isUpnp, startIndex, isVideo) {
    // if player.model is set assumes a new playlist must be set
    if (model) {
        if (isUpnp)
            mediaPlayer.generatePlaylistUPnP(model, startIndex, model.count, isVideo)
        else
            mediaPlayer.generatePlaylistLocal(model, startIndex, model.count, isVideo)
        return
    }

    // model is not set, checks if playlist is set
    if (mediaPlayer.playing)
        return // everything is fine

    // we don't have a model and we don't have a playlist: something is wrong somewhere...
    console.log("Impossible to init MediaPlayer in QML: no model and no playlist to play")
}

function initVideoPlayer(mediaPlayer, model, isUpnp, startIndex) {
    _initPlayer(mediaPlayer, model, isUpnp, startIndex, true)
}

function initAudioPlayer(mediaPlayer, model, isUpnp, startIndex) {
    _initPlayer(mediaPlayer, model, isUpnp, startIndex, false)
}
