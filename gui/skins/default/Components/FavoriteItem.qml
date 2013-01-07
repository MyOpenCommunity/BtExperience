import QtQuick 1.1
import BtExperience 1.0

QuickLink {
    id: favoriteItem

    page: ""
    imageSource: "../images/profiles/web.jpg"

    onClicked: {
        global.browser.displayUrl(itemObject.address)
    }
}
