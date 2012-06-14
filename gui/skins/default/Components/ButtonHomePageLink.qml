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
        width: text.width

        SvgImage {
            id: imageIcon
            source: button.icon
            anchors.horizontalCenter: text.horizontalCenter
        }

        UbuntuLightText {
            id: text
            color: "#000000"
            text: button.text
            font.pixelSize: 13
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
