import QtQuick 1.1
import Components 1.0
import Components.Antintrusion 1.0
import "js/datetime.js" as DateTime


SystemPage {
    id: antintrusion
    source: "images/burlagar-alarm.jpg"
    text: qsTr("antintrusion")
    rootColumn: Component { AntintrusionSystem {} }
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

    function showLog() {
        antintrusion.rootObject.showAlarmLog()
    }
}

