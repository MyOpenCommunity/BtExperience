import QtQuick 1.1

Image {
    id: button
    source: "../images/common/button_navigation_column.svg"
    signal clicked
    Image {
        id: systemIcon
        source: "../images/common/icon_systems.svg"
        anchors.centerIn: parent
    }
    MouseArea {
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
            target: systemIcon
            source: "../images/common/icon_systems_p.svg"
        }
    }
}
