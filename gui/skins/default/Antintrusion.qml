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
        opacity: 0.7
        z: 1
        visible: false
        MouseArea { anchors.fill: parent }
    }

    KeyPad {
        id: keypad
        z: 2
        visible: false
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        mainText: qsTr("imposta zone")
        keypadText: qsTr("inserisci il codice")
        onCancelClicked: antintrusion.state = ""
    }

    states: [
        State {
            name: "keypadShown"
            PropertyChanges { target: keypad; visible: true }
            PropertyChanges { target: darkRect; visible: true }
        }
    ]
}

