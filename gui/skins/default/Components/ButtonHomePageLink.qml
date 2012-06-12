import QtQuick 1.1
import Components.Text 1.0


SvgImage {
    id: button
    property string text: ""
    property url icon: ""
    property url sourcePressed: ""

    signal clicked

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: button.clicked()
    }

    Column {
        spacing: 5
        anchors.centerIn: parent
        SvgImage {
            id: imageIcon
            source: button.icon
        }

        UbuntuLightText {
            id: text
            color: "#000000"
            text: button.text
            font.pixelSize: 13
            anchors.horizontalCenter: imageIcon.horizontalCenter
        }
    }


    states: State {
        name: "pressed"
        when: mouseArea.pressed
        PropertyChanges {
            target: button
            source: sourcePressed
        }
        PropertyChanges {
            target: text
            color: "#FFFFFF"
        }
    }
}
