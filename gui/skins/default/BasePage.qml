import QtQuick 1.1
import Components 1.0
import "js/MainContainer.js" as Container


Image {
    id: page

    property alias popupLoader: popupLoader
    property alias constants: constants
    // all pages are visible, so browser must be shown/hidden not depending on
    // visible property, but we need a new property to know if we are on top
    // of the stack or not
    // browser will be visible when the following property is true
    property bool topPage: false
    // Warning: this property must be considered constant.
    property string _pageName: ""

    signal popupDismissed

    // The alert management and API.
    function showAlert(sourceElement, message) {
        popupLoader.setComponent(alertComponent, {"message": message, "source": sourceElement})
        popupLoader.item.closeAlert.connect(closeAlert)
        page.state = "alert"
    }

    function closeAlert() {
        closePopup()
    }

    // Warning: please note that popupLoader doesn't take ownership of the
    // component that you have created. If you try to install a component which
    // may be destroyed before user input finished, it will not work.
    // Example: create a popup from a MenuColumn that immediately after is
    // destroyed.
    function installPopup(sourceComponent, properties) {
        popupLoader.setComponent(sourceComponent, properties)
        popupConnection.target = popupLoader.item
        page.state = "popup"
    }

    function processLaunched(processHandle) {
        page.state = "pageLoading"
        privateProps.process = processHandle
    }

    // The hooks called by the Stack javascript manager. See also PageAnimation
    // If a page want to use a different animation, reimplement these hooks.
    function pushInStart() {
        var animation = Container.mainContainer.animation
        animation.page = page
        if (animation.pushIn) {
            animation.pushIn.complete()
            animation.pushIn.start()
        }
    }

    function popInStart() {
        var animation = Container.mainContainer.animation
        animation.page = page
        if (animation.popIn) {
            animation.popIn.complete()
            animation.popIn.start()
        }
    }

    function pushOutStart() {
        var animation = Container.mainContainer.animation
        animation.page = page
        if (animation.pushOut) {
            animation.pushOut.complete()
            animation.pushOut.start()
        }
    }

    function popOutStart() {
        var animation = Container.mainContainer.animation
        animation.page = page
        if (animation.popOut) {
            animation.popOut.complete()
            animation.popOut.start()
        }
    }

    width: 1024
    height: 600
    sourceSize.width: 1024
    sourceSize.height: 600

    MouseArea {
        id: blockClicks
        anchors.fill: parent
    }

    Component {
        id: alertComponent
        Alert {
        }
    }

    Connections {
        id: popupConnection
        target: null
        onClosePopup: closePopup()
        ignoreUnknownSignals: true
    }

    // When the interval between two popups installations is smaller than the
    // opacity transition duration, the blackBg remains visible even if page
    // state is default. Example: wrong credentials in the HTTPS authentication
    // window.
    // As a workaround use the visible property.
    Rectangle {
        id: blackBg
        anchors.fill: parent
        color: "black"
        opacity: 0
        z: 9
        visible: false

        // A trick to block mouse events handled by the underlying page
        MouseArea {
            anchors.fill: parent
        }

        Behavior on opacity {
            NumberAnimation { duration: constants.alertTransitionDuration }
        }
    }

    Pannable {
        id: pannable
        anchors.fill: parent
        z: 10

        LoaderWithProps {
            id: popupLoader
            opacity: 0
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenterOffset: parent.childOffset
            Behavior on opacity {
                NumberAnimation { duration: constants.alertTransitionDuration }
            }
        }
    }

    function closePopup() {
        page.state = ""
        popupLoader.setComponent(undefined)
        page.popupDismissed()
    }

    Constants {
        id: constants
    }

    QtObject {
        id: privateProps
        property QtObject process: null

        function processHide() {
            page.state = ""
            process = null
        }
    }

    SvgImage {
        id: loadingIndicator

        source: "images/common/ico_caricamento_white.svg"
        anchors.centerIn: blackBg
        visible: false
        z: blackBg.z + 1

        Timer {
            id: loadingTimer
            interval: 250
            repeat: true
            onTriggered: loadingIndicator.rotation += 45
        }

        states: [
            State {
                name: "indicatorShown"
                PropertyChanges { target: loadingIndicator; visible: true }
                PropertyChanges { target: loadingTimer; running: true }
            }
        ]
    }

    Connections {
        id: processConnection
        target: privateProps.process
        onRunningChanged: {
            if (!global.browser.running)
                privateProps.processHide()
        }

        onAboutToHide: privateProps.processHide()
        onCreateQuicklink: myHomeModels.createQuicklink(-1, type, name, address)
    }

    onTopPageChanged: {
        if (privateProps.process)
            privateProps.process.visible = topPage
    }
    Component.onDestruction: {
        if (privateProps.process)
            privateProps.process.visible = false
    }

    states: [
        State {
            name: "alert"
            PropertyChanges { target: popupLoader; opacity: 1 }
            PropertyChanges { target: blackBg; opacity: 0.85; visible: true }
        },
        State {
            name: "popup"
            PropertyChanges { target: popupLoader; opacity: 1 }
            PropertyChanges { target: blackBg; opacity: 0.7; visible: true }
        },
        State {
            name: "pageLoading"
            PropertyChanges { target: blackBg; opacity: 0.7; visible: true }
            PropertyChanges { target: loadingIndicator; state: "indicatorShown" }
        }
    ]
}

