import QtQuick 1.1
import Components 1.0
import "js/MainContainer.js" as Container


/**
  \ingroup Core

  \brief Component for a base page.

  This component implements all common features for all pages.

  A base page defines what are called page popups.
  This kind of popup is entirely managed by a single page.
  Page is responsible for popup creation and destruction.
  The graphical management for a popup is done in the popup state.
  When a popup is closed, the page emits BasePage::popupDismissed.
  Every component may be used as popup. This component must
  define the BasePage::closePopup signal. When you are done and you want to close
  the popup, simply emit the BasePage::closePopup signal and this component will make
  all the cleaning for you. See FavoriteEditPopup as an example
  for such a popup.

  The base page contains methods to manage page transition animations. They
  are needed to support the Stack protocol for application pages.

  The base page is responsible for the browser housekeeping, too.
  The browser is implemented in a separate process, but must coordinates
  itself with the main application. The base page shows or hides the browser
  process when needed.

  In some cases, an application restart is needed. For example, when changing
  system date and time, the application needs to be restarted for changes to
  take effect. A loadingIndicator puts the page in a loading graphical state
  while waiting for restarting. In this state no interaction with the
  application is possible, so maximum care is mandatory to avoid application
  deadlock. See SettingsDateTime for an example of such a feature.
  */
Image {
    id: page

    /** type:LoaderWithProps The object "receiving" the popup component */
    property alias popupLoader: popupLoader
    /** type:Constants Some common constants used in BasePage */
    property alias constants: constants
    /**
       Is this page on top of the stack?

       All pages are visible, so browser must be shown/hidden not depending on
       visible property, but we need a new property to know if we are on top
       of the stack or not; browser will be visible when the property is true
      */
    property bool topPage: false
    /** The name of the page. Must be considered constant. */
    property string _pageName: ""

    /**
      The popup has been closed
     */
    signal popupDismissed

    function showAlert(sourceElement, message) {
        popupLoader.setComponent(alertComponent, {"message": message, "source": sourceElement})
        popupLoader.item.closeAlert.connect(closeAlert)
        page.state = "alert"
    }

    function closeAlert() {
        closePopup()
    }

    /**
      Creates a customizable popup associated to this page.
      The source component must emit the BasePage::closePopup signal at proper
      times. Due to the fact the popup is customizable, a properties argument
      is provided. You can use it to pass properties to the popup at creation
      time.
      \warning popupLoader doesn't take ownership of the component you create.
      If you try to install a component which may be destroyed before user
      interaction finishes, it will not work. For example, if you create a
      popup in a menu that is immediatly destroyed will lead to problems.
      @param type:Item sourceComponent The customized popup
      @param type:array properties Properties to be passed to popup at creation
     */
    function installPopup(sourceComponent, properties) {
        popupLoader.setComponent(sourceComponent, properties)
        popupConnection.target = popupLoader.item
        page.state = "popup"
    }

    /**
      Launches the browser process.
      */
    function processLaunched(processHandle) {
        page.state = "pageLoading"
        privateProps.process = processHandle
    }

    /**
      Hook used by the Stack javascript manager.
      Reimplement this in a page if you want a different animation there.
      \sa PageAnimation
      */
    function pushInStart() {
        var animation = Container.mainContainer.animation
        animation.page = page
        if (animation.pushIn) {
            animation.pushIn.complete()
            animation.pushIn.start()
        }
    }

    /**
      Hook used by the Stack javascript manager.
      Reimplement this in a page if you want a different animation there.
      \sa PageAnimation
      */
    function popInStart() {
        var animation = Container.mainContainer.animation
        animation.page = page
        if (animation.popIn) {
            animation.popIn.complete()
            animation.popIn.start()
        }
    }

    /**
      Hook used by the Stack javascript manager.
      Reimplement this in a page if you want a different animation there.
      \sa PageAnimation
      */
    function pushOutStart() {
        var animation = Container.mainContainer.animation
        animation.page = page
        if (animation.pushOut) {
            animation.pushOut.complete()
            animation.pushOut.start()
        }
    }

    /**
      Hook used by the Stack javascript manager.
      Reimplement this in a page if you want a different animation there.
      \sa PageAnimation
      */
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
        Alert {}
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

    /**
       Closes the popup.
      */
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

