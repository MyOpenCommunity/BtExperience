import QtQuick 1.1
import Components 1.0
import Components.Text 1.0


Item {
    id: buttonsColumn
    property bool backButton: true
    property bool systemsButton: true
    property alias text: label.text

    signal backClicked
    signal systemsClicked

    // private implementation
    width: backButton.width

    Column {
        id: column
        spacing: 1


        ButtonBack {
            id: backButton
            visible: buttonsColumn.backButton
            onClicked: buttonsColumn.backClicked()
        }

        ButtonSystems {
            visible: buttonsColumn.systemsButton
            onClicked: buttonsColumn.systemsClicked()
        }
    }
    Rectangle {
        id: background
        color: "white"
        opacity: 0.6
        width: backButton.width

        anchors {
            top: column.bottom
            bottom: parent.bottom
            left: column.left
        }
    }

    UbuntuLightText {
        id: label
        color: "black"
        anchors.centerIn: background
        rotation: 270
        font.pointSize: 24
    }
}
