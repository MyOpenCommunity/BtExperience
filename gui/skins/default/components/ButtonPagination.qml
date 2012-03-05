import QtQuick 1.1

Image {
    id: pageButton
    property int pageNumber: 1
    signal clicked(int pageNumber)

    width: 42
    height: 35
    source: "../images/common/btn_NumeroPagina.png"

    Text {
        id: label
        text: pageButton.pageNumber
        anchors.centerIn: parent
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: pageButton.clicked(pageButton.pageNumber)
    }

    // TODO: states: pressed, released
}
