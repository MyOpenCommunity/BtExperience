import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import "js/Stack.js" as Stack
import "js/MainContainer.js" as Container
import "js/datetime.js" as DateTime


Image {
    id: page
    width: 1024
    height: 600
    asynchronous: true
    sourceSize.width: 1024
    sourceSize.height: 600

    property alias popupLoader: popupLoader
    property alias constants: constants

    // Warning: this property is an internal detail, it's not part of the public
    // interface
    property string _pageName: ""

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

    // Alarm Popup management and API
    Component {
        id: alarmComponent
        AlarmPopup {
        }
    }

    function installPopup(sourceComponent) {
        popupLoader.sourceComponent = sourceComponent
        popupLoader.item.closePopup.connect(closePopup)
        page.state = "popup"
    }

    function showAlarmPopup(type, zone, number, time) {
        popupLoader.sourceComponent = alarmComponent
        popupLoader.item.alarmDateTime = DateTime.format(time)["time"] + " - " + DateTime.format(time)["date"]
        // for location, firstly we have alarm type
        var location = privateProps.antintrusionNames.get('ALARM_TYPE', type)
        location += ": "
        // lastly, we have zone and description (or number if it lacks)
        if (type === AntintrusionAlarm.Technical)
            location += qsTr("aux") + " " + number
        else if (number >= 1 && number <= 8 && zone !== null)
            location += qsTr("zone") + " " + zone.name
        else
            location += qsTr("zone") + " " + number
        popupLoader.item.alarmLocation = location
        popupLoader.item.ignoreClicked.connect(closePopup)
        popupLoader.item.alarmLogClicked.connect(closeAlarmAndShowLog)
        page.state = "popup"
    }

    function closeAlarmAndShowLog() {
        closePopup()
        var currentPage = Stack.currentPage()
        if (currentPage._pageName !== "Antintrusion")
            currentPage = Stack.openPage("Antintrusion.qml")
        currentPage.showLog()
    }

    // needed to translate antintrusion names in popup
    QtObject {
        id: privateProps
        property QtObject antintrusionNames: AntintrusionNames { }
    }

    // The hooks called by the Stack javascript manager. See also PageAnimation
    // If a page want to use a different animation, reimplement these hooks.
    function pushInStart() {
        var animation = Container.mainContainer.animation
        animation.page = page
        if (animation.pushIn)
            animation.pushIn.start()
    }

    function popInStart() {
        var animation = Container.mainContainer.animation
        animation.page = page
        if (animation.popIn)
            animation.popIn.start()
    }

    function pushOutStart() {
        var animation = Container.mainContainer.animation
        animation.page = page
        if (animation.pushOut)
            animation.pushOut.start()
    }

    function popOutStart() {
        var animation = Container.mainContainer.animation
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

