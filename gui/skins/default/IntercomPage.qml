import QtQuick 1.1
import Components 1.0
import "js/Stack.js" as Stack


/**
  \ingroup Core

  \brief The intercom management page.

  This page is responsible to manage incoming intercom calls. When an
  intercom call arrives, the EventManager shows it up.
  The page opens a popup containing the ControlCall component which is the
  true responsible of the call management. When call terminates, application
  resumes from the point of last execution.
  */
BasePage {
    id: page

    /** The C++ model object managing the intercom call */
    property variant callObject

    opacity: 0
    _pageName: "IntercomPage"

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
