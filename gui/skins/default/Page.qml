import QtQuick 1.1
import Components 1.0
import "js/Stack.js" as Stack
import "js/EventManager.js" as EventManager


BasePage {
    id: page

    property alias toolbar: toolbar
    property alias navigationBar: navigationBar
    property alias text: navigationBar.text
    property alias showBackButton: navigationBar.backButton
    property alias showSystemsButton: navigationBar.systemsButton

    function homeButtonClicked() {
        Stack.backToHome()
    }

    function backButtonClicked() {
        Stack.popPage()
    }

    function systemsButtonClicked() {
    }

    ToolBar {
        id: toolbar
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        onHomeClicked: homeButtonClicked()
    }

    NavigationBar {
        id: navigationBar
        anchors {
            top: toolbar.bottom
            topMargin: constants.navbarTopMargin
            left: parent.left
            bottom: parent.bottom
        }
        backButton: true
        systemsButton: false

        onBackClicked: backButtonClicked()
        onSystemsClicked: systemsButtonClicked()
    }

    ConfirmationBar {
        id: scenarioBar

        height: 45
        z: 2
        opacity: EventManager.eventManager.scenarioRecording ? 1.0 : 0.0
        anchors {
            top: toolbar.bottom
            topMargin: -12
            left: parent.left
            right: parent.right
        }
    }
}
