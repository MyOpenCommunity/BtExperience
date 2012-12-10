import QtQuick 1.1
import BtObjects 1.0
import "../js/Stack.js" as Stack


QuickLink {
    id: favoriteItem

    page: ""
    imageSource: "../images/profiles/webcam.jpg" // TODO use right image when available

    onClicked: {
        var urls = []
        urls.push(itemObject.address)
        global.audioVideoPlayer.generatePlaylistWebRadio(urls, 0, 1)
        Stack.pushPage("AudioVideoPlayer.qml", {"isVideo": false})
    }
}
