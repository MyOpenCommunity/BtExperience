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

    // This Item is only a positioner element for the text. Text is rotated
    // relative to the original position of the text (excluding alignment etc)
    // but centering and anchoring is done relative to the size of the Item
    // class (which is a parent of Text element).
    // Using an Item for positioning makes it easier to get it right.
    Item {
        // swap width <-> height because we are rotating, anchors.fill is not
        // going to work
        width: background.height
        height: background.width
        anchors.centerIn: background
        rotation: 270

        UbuntuLightText {
            id: label
            anchors.fill: parent
            color: "#343434"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 32
            elide: Text.ElideRight
        }
    }
}
