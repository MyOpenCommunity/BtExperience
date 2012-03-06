import QtQuick 1.1

Image {
    id: button
    width: 43
    height: 45
    property string insideImage: "../images/common/successivo.png"
    signal clicked

    source: "../images/common/btn_ModTacciaAudio.png"

    Image {
        anchors.centerIn: parent
        source: insideImage
    }

    MouseArea {
        anchors.fill: parent
        onClicked: button.clicked()
    }
}
