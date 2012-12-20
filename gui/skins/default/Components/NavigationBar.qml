import QtQuick 1.1
import Components 1.0
import Components.Text 1.0


Item {
    id: buttonsColumn
    property bool backButton: true
    property bool systemsButton: true
    property bool settingsButton: true
    property bool roomsButton: true
    property bool multimediaButton: true
    property alias text: label.text

    signal backClicked
    signal systemsClicked
    signal settingsClicked
    signal roomsClicked
    signal multimediaClicked

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

        ButtonSettings {
            visible: buttonsColumn.settingsButton
            onClicked: buttonsColumn.settingsClicked()
        }

        ButtonRooms {
            visible: buttonsColumn.roomsButton
            onClicked: buttonsColumn.roomsClicked()
        }

        ButtonMultimedia {
            visible: buttonsColumn.multimediaButton
            onClicked: buttonsColumn.multimediaClicked()
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
        color: "#343434"
        anchors.centerIn: background
        rotation: 270
        font.pixelSize: 32
    }
}
