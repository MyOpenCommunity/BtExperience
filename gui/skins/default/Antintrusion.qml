import QtQuick 1.1
import Components 1.0
import Components.Antintrusion 1.0
import "js/datetime.js" as DateTime


SystemPage {
    id: antintrusion
    source: "images/background/burglar_alarm.jpg"
    text: qsTr("antintrusion")
    rootColumn: Component { AntintrusionSystem {} }
    names: AntintrusionNames { }

    // KeyPad management and API
    function showKeyPad(title, errorMessage, okMessage) {
        installPopup(keypadComponent, {"mainLabel": title, "errorLabel": errorMessage, "okLabel": okMessage})
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
}

