import QtQuick 1.1

Image {
    id: button
    source: "../images/common/btn_sistemi.png"
    height: 50
    signal clicked

    MouseArea {
        id: mousearea
        anchors.fill: parent
        onClicked: button.clicked()
    }
    states: State {
        name: "pressed"
        when: mousearea.pressed === true;
//         PropertyChanges { target: button; source: "images/common/btn_sistemiP.png" }
    }
}
