import QtQuick 1.1
import "js/Stack.js" as Stack

Image {
    id: page
    width: 1024
    height: 600
    asynchronous: true
    sourceSize.width: 1024
    sourceSize.height: 600

    property alias lightFont: lightFont
    property alias regularFont: regularFont
    property alias semiBoldFont: semiBoldFont
    property alias popupLoader: popupLoader

    FontLoader { id: lightFont; source: "MyriadPro-Light.otf" }
    FontLoader { id: regularFont; source: "MyriadPro-Regular.otf" }
    FontLoader { id: semiBoldFont; source: "MyriadPro-Semibold.otf" }

    // The alert management and API.
    function showAlert(sourceElement, message) {
        popupLoader.sourceComponent = alertComponent
        popupLoader.item.closeAlert.connect(closeAlert)
        popupLoader.item.message = message
        popupLoader.item.source = sourceElement
        page.state = "alert"
    }

    function closeAlert() {
        closePopup()
    }

    Component {
        id: alertComponent
        Alert {
        }
    }

    // The hooks called by the Stack javascript manager. See also PageAnimation
    // If a page want to use a different animation, reimplement this hooks.
    function pushInStart() {
        var animation = Stack.container.animation.item
        animation.page = page
        if (animation.pushIn)
            animation.pushIn.start()
    }

    function popInStart() {
        var animation = Stack.container.animation.item
        animation.page = page
        if (animation.popIn)
            animation.popIn.start()
    }

    function pushOutStart() {
        var animation = Stack.container.animation.item
        animation.page = page
        if (animation.pushOut)
            animation.pushOut.start()
    }

    function popOutStart() {
        var animation = Stack.container.animation.item
        animation.page = page
        if (animation.popOut)
            animation.popOut.start()
    }

    // The management for popups using by alerts, keypad, etc..
    Rectangle {
        id: blackBg
        anchors.fill: parent
        color: "black"
        opacity: 0
        z: 9

        // A trick to block mouse events handled by the underlying page
        MouseArea {
            anchors.fill: parent
        }

        Behavior on opacity {
            NumberAnimation { duration: constants.alertTransitionDuration }
        }
    }

    Loader {
        id: popupLoader
        opacity: 0
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        z: 10
        Behavior on opacity {
            NumberAnimation { duration: constants.alertTransitionDuration }
        }
    }

    function closePopup() {
        page.state = ""
        popupLoader.sourceComponent = undefined
    }

    Constants {
        id: constants
    }


    states: [
        State {
            name: "alert"
            PropertyChanges { target: popupLoader; opacity: 1 }
            PropertyChanges { target: blackBg; opacity: 0.85 }
        },
        State {
            name: "popup"
            PropertyChanges { target: popupLoader; opacity: 1 }
            PropertyChanges { target: blackBg; opacity: 0.7 }
        }
    ]
}

