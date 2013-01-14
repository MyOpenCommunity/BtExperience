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
            callerMode: false // incoming calls
            onClosePopup: Stack.popPage()
        }
    }

    Behavior on opacity {
        NumberAnimation { duration: constants.alertTransitionDuration }
    }

    Component.onCompleted: {
        installPopup(popupComponent, {dataObject: page.callObject, state: "callFrom"})
        popupLoader.item.dataObject.callEnded.connect(popupLoader.item.callEndedCallBack)
    }
}
