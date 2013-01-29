import QtQuick 1.1
import BtObjects 1.0
import Components.Popup 1.0


QuickLink {
    id: favoriteItem

    property variant pageObject

    page: ""
    imageSource: "../images/profiles/scenario_quicklink.png"

    onClicked: {
        if (itemObject.btObject.activate) {
            itemObject.btObject.activate()
            pageObject.installPopup(feedback)
            return
        }

        if (itemObject.btObject.start) {
            itemObject.btObject.start()
            return
        }
    }

    Component {
        id: feedback
        FeedbackPopup { isOk: true; text: qsTr("Command sent") }
    }
}
