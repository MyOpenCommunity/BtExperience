import QtQuick 1.1
import Components 1.0

Column {
    id: buttonsColumn
    property bool backButton: true
    property bool systemsButton: true

    signal backClicked
    signal systemsClicked

    // private implementation
    width: backButton.width
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
