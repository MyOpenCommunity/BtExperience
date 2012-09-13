import QtQuick 1.1

Image {
    id: button
    width: 43
    height: 45
    property alias insideImage: internalImage.source
    signal clicked

    source: "../images/common/btn_ModTacciaAudio.png"

    Image {
        id: internalImage
        anchors.centerIn: parent
        source: "../images/common/successivo.png"
    }

    BeepingMouseArea {
        anchors.fill: parent
        onClicked: button.clicked()
    }
}
