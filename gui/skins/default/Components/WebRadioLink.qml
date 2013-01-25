import QtQuick 1.1
import BtObjects 1.0
import "../js/Stack.js" as Stack


QuickLink {
    id: favoriteItem

    page: ""
    imageSource: "../images/profiles/web.jpg"

    onClicked: {
        var items = []
        items.push(itemObject)
        global.audioVideoPlayer.generatePlaylistWebRadio(items, 0, 1)
        Stack.pushPage("AudioPlayer.qml")
    }
}
