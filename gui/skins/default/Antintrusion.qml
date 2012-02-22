import QtQuick 1.1

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
        Behavior on opacity { NumberAnimation { duration: 200 } }
    }

    KeyPad {
        id: keypad
        z: 2
        opacity: 0
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        helperLabel: qsTr("inserisci il codice")

        onCancelClicked: antintrusion.state = ""
        Behavior on opacity { NumberAnimation { duration: 200 } }
    }

    states: [
        State {
            name: "keypadShown"
            PropertyChanges { target: keypad; opacity: 1 }
            PropertyChanges { target: darkRect; opacity: 0.7 }
        }
    ]

    function showKeyPad(title, errorMessage, okMessage) {
        keypad.mainLabel = title
        keypad.errorLabel = errorMessage
        keypad.okLabel = okMessage
        antintrusion.state = "keypadShown"
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

