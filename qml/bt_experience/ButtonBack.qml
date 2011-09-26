import QtQuick 1.1

Image {
    id: button
    source: "common/tasto_indietro.png"
    width: 65
    height: 65
    signal clicked
    Image {
        id: arrowLeft
        source: "common/freccia_sx.png"
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
//         PropertyChanges { target: button; source: "common/tasto_indietroP.png" }
//         PropertyChanges { target: arrowLeft; source: "common/freccia_sxS.png" }
    }
}
