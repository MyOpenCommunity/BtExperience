import QtQuick 1.1

SystemPage {
    id: antintrusion
    source: "images/automazione.jpg"
    text: qsTr("antintrusione")
    rootElement: "AntintrusionSystem.qml"

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
        keypadText: qsTr("inserisci il codice")
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

    onRootObjectChanged: {
        if (rootObject !== undefined)
            rootObject.showKeyPad.connect(showKeyPad)
    }


    function showKeyPad(title) {
        keypad.mainText = title
        antintrusion.state = "keypadShown"
    }
}

