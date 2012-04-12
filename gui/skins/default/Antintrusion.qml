import QtQuick 1.1
import "js/datetime.js" as DateTime
import Components 1.0


SystemPage {
    id: antintrusion
    source: "images/antintrusion.jpg"
    text: qsTr("antintrusion")
    rootElement: "Components/Antintrusion/AntintrusionSystem.qml"
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

