import QtQuick 1.1
import BtObjects 1.0


QuickLink {
    id: favoriteItem

    page: ""
    imageSource: "../images/profiles/scenario_quicklink.png"

    onClicked: {
        if (itemObject.btObject.activate) {
            itemObject.btObject.activate()
            return
        }

        if (itemObject.btObject.start) {
            itemObject.btObject.start()
            return
        }
    }
}
