import QtQuick 1.1

Image {
    id: button
    source: "../images/common/btn_indietro.png"
    width: 50
    height: 50
    signal clicked
    Image {
        id: arrowLeft
        source: "../images/common/freccia_sx.png"
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0
    }
    MouseArea {
        id: mousearea
        anchors.fill: parent
        onClicked: button.clicked()
    }
    states: State {
        name: "pressed"
        when: mousearea.pressed === true;
//         PropertyChanges { target: button; source: "images/common/btn_indietroP.png" }
//         PropertyChanges { target: arrowLeft; source: "images/common/freccia_sxS.png" }
    }
}
