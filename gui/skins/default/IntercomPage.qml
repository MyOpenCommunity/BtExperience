/**
  * The page responsible for incoming Intercom call management.
  */

import QtQuick 1.1
import Components 1.0
import "js/Stack.js" as Stack


BasePage {
    id: page

    property variant callObject

    opacity: 0

    Component {
        id: popupComponent
        ControlCall {
            id: popupControl
            onClosePopup: Stack.popPage()
        }
    }

    Behavior on opacity {
        NumberAnimation { duration: constants.alertTransitionDuration }
    }

    Component.onCompleted: {
        popupLoader.sourceComponent = popupComponent
        state = "popup"
        popupLoader.item.dataObject = page.callObject
        popupLoader.item.state = "callFrom"
        popupLoader.item.dataObject.callEnded.connect(popupLoader.item.callEndedCallBack)
    }
}
