import QtQuick 1.1

SystemPage {
    id: antintrusion
    source: "images/antintrusion.jpg"
    text: qsTr("antintrusione")
    rootElement: "AntintrusionSystem.qml"
    names: AntintrusionNames { }

    // KeyPad management and API
    function showKeyPad(title, errorMessage, okMessage) {
        popupLoader.sourceComponent = keypadComponent
        popupLoader.item.cancelClicked.connect(closeKeyPad)
        popupLoader.item.mainLabel = title
        popupLoader.item.errorLabel = errorMessage
        popupLoader.item.okLabel = okMessage
        antintrusion.state = "popup"
    }

    function closeKeyPad() {
        closePopup()
    }

    function resetKeyPad() {
        popupLoader.item.textInserted = ""
        popupLoader.item.state = ""
    }

    Component {
        id: keypadComponent
        KeyPad {
            helperLabel: qsTr("inserisci il codice")
        }
    }

    // Alarm Popup management and API
    Component {
        id: alarmComponent
        AlarmPopup {
        }
    }

    function showAlarmPopup(type, zone, time) {
        popupLoader.sourceComponent = alarmComponent
        popupLoader.item.alarmDateTime = Qt.formatDateTime(time, "hh:mm - dd/MM/yyyy")
        popupLoader.item.alarmLocation = antintrusion.names.get('ALARM_TYPE', type) + ": zone " + zone.objectId + " - " + zone.name
        popupLoader.item.ignoreClicked.connect(closeAlarmPopup)
        popupLoader.item.alarmLogClicked.connect(closeAlarmAndShowLog)
        antintrusion.state = "popup"
    }

    function closeAlarmPopup() {
        closePopup()
    }

    function closeAlarmAndShowLog() {
        closePopup()
        antintrusion.rootObject.showAlarmLog()
    }
}

