import QtQuick 1.1
import "js/datetime.js" as DateTime
import Components 1.0

SystemPage {
    id: antintrusion
    source: "images/antintrusion.jpg"
    text: qsTr("antintrusion")
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
            helperLabel: qsTr("enter code")
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
        popupLoader.item.alarmDateTime = DateTime.format(time)["time"] + " - " + DateTime.format(time)["date"]
        popupLoader.item.alarmLocation = antintrusion.names.get('ALARM_TYPE', type) + ": " + qsTr("zone %1 - %2").arg(zone.objectId).arg(zone.name)
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

