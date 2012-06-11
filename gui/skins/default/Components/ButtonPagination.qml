import QtQuick 1.1
import Components.Text 1.0


Image {
    id: pageButton
    property int pageNumber: 1
    property alias enabled: mouseArea.enabled
    signal clicked(int pageNumber)

    width: 42
    height: 35
    source: "../images/common/btn_NumeroPagina.png"

    UbuntuLightText {
        id: label
        text: pageButton.pageNumber
        anchors.centerIn: parent
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: pageButton.clicked(pageButton.pageNumber)
    }

    states: [
        State {
            name: "selected"
            PropertyChanges {
                target: label
                color: "red"
                font.bold: true
            }
        }
    ]

    // TODO: states: pressed, released
}
