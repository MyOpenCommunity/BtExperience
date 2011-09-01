import QtQuick 1.1
import "Stack.js" as Stack


Image {
    id: page
    width:  800
    height: 480

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

    states: [
        State {
            name: "offscreen_right"
            PropertyChanges {
                target: page
                x: 800
            }
        },
        State {
            name: "offscreen_left"
            PropertyChanges {
                target: page
                x: -800
            }
        },
        State {
            name: "alert"

            PropertyChanges {
                target: alert
                opacity: 1
            }

            PropertyChanges {
                target: blackBg
                opacity: 0.85
            }
        }

    ]
    transitions: [
        Transition {
            from: 'offscreen_right'; to: ''
            SequentialAnimation {
                PropertyAnimation { properties: "x"; duration: 1000; easing.type: Easing.OutBack }
                ScriptAction { script: Stack.changePageDone(); }
            }
        },
            Transition {
            from: 'offscreen_left'; to: ''
            SequentialAnimation {
                PropertyAnimation { properties: "x"; duration: 1000; easing.type: Easing.OutBack }
                ScriptAction { script: Stack.changePageDone(); }
            }
        }
    ]
}

