import QtQuick 1.1
import "constants.js" as Constants

SystemPage {
    id: antintrusion
    source: "images/antintrusion.jpg"
    text: qsTr("antintrusione")
    rootElement: "AntintrusionSystem.qml"
    names: AntintrusionNames { }

    property alias keypadObject: keypad

    Rectangle {
        id: darkRect
        anchors.fill: parent
        color: "black"
        opacity: 0
        z: 1
        MouseArea { anchors.fill: parent }
        Behavior on opacity { NumberAnimation { duration: Constants.alertTransitionDuration } }
    }

    KeyPad {
        id: keypad
        z: 2
        opacity: 0
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        helperLabel: qsTr("inserisci il codice")

        onCancelClicked: antintrusion.state = ""
        Behavior on opacity { NumberAnimation { duration: Constants.alertTransitionDuration } }
    }

    AlarmPopup {
        id: alarmPopup
        z: 2
        opacity: 0
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        onIgnoreClicked: antintrusion.state = ""
        onAlarmLogClicked: {
            antintrusion.state = ""
            antintrusion.rootObject.showAlarmLog();
        }

        Behavior on opacity { NumberAnimation {duration: Constants.alertTransitionDuration } }
    }

    states: [
        State {
            name: "keypadShown"
            PropertyChanges { target: keypad; opacity: 1 }
            PropertyChanges { target: darkRect; opacity: 0.7 }
        },
        State {
            name: "alarmShown"
            PropertyChanges { target: alarmPopup; opacity: 1 }
            PropertyChanges { target: darkRect; opacity: 0.7 }
        }
    ]

    function showKeyPad(title, errorMessage, okMessage) {
        keypad.mainLabel = title
        keypad.errorLabel = errorMessage
        keypad.okLabel = okMessage
        antintrusion.state = "keypadShown"
    }

    function showAlarmPopup(type, zone, time) {
        antintrusion.state = "alarmShown"
        alarmPopup.alarmDateTime = Qt.formatDateTime(time, "hh:mm - dd/MM/yyyy");
        alarmPopup.alarmLocation = antintrusion.names.get('ALARM_TYPE', type) + ": zone " + zone.objectId + " - " + zone.name
    }

    function closeKeyPad() {
        antintrusion.state = ""
        resetKeyPad();
    }

    function resetKeyPad() {
        keypad.textInserted = ""
        keypad.state = ""
    }
}

