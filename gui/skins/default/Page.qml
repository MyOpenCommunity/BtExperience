import QtQuick 1.1
import "Stack.js" as Stack


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

    property alias alertMessage: alert.message

    FontLoader { id: lightFont; source: "MyriadPro-Light.otf" }
    FontLoader { id: regularFont; source: "MyriadPro-Regular.otf" }
    FontLoader { id: semiBoldFont; source: "MyriadPro-Semibold.otf" }

    function showAlert(sourceElement, message) {
        alert.hideAlert.connect(hideAlert)
        alert.message = message
        alert.source = sourceElement
        page.state = "alert"
    }

    function hideAlert() {
        page.state = ""
    }

    function pushInStart() {
        animation.item.pushInStart()
    }

    function popInStart() {
        animation.item.popInStart()
    }

    function pushOutStart() {
        animation.item.pushOutStart()
    }

    function popOutStart() {
        animation.item.popOutStart()
    }

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
            NumberAnimation { duration: 200 }
        }
    }

    Alert {
        id: alert
        opacity: 0
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        z: 10

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }

    }

    Connections {
        target: animation.item
        onAnimationCompleted: {
            Stack.changePageDone()
        }
    }

    Loader {
        id: animation;
        source: "FadeAnimation.qml"
        onLoaded: {
            item.page = page
        }
    }
}

