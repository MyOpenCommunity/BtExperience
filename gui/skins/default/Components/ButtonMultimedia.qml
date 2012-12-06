import QtQuick 1.1

Image {
    id: button
    source: "../images/common/button_navigation_column.svg"
    signal clicked
    Image {
        id: multimediaIcon
        source: "../images/common/ico_multimedia.svg"
        anchors.centerIn: parent
    }
    BeepingMouseArea {
        id: mousearea
        anchors.fill: parent
        onClicked: button.clicked()
    }
    states: State {
        name: "pressed"
        when: mousearea.pressed === true;
        PropertyChanges {
            target: button
            source: "../images/common/button_navigation_column_p.svg"
        }
        PropertyChanges {
            target: multimediaIcon
            source: "../images/common/ico_multimedia_P.svg"
        }
    }
}
