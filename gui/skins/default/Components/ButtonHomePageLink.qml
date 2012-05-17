import QtQuick 1.1

SvgImage {
    id: button
    opacity: 0.8
    property string text: ""
    property url sourcePressed: ""
    property bool textFirst: true
    property int textLeftMargin: 0
    signal clicked

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: button.clicked()
    }

    Text {
        id: text
        color: "#000000"
        text: parent.text
        font.pixelSize: 13
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.textFirst ? parent.top : undefined
        anchors.topMargin: parent.textFirst ? 30 : 0

        anchors.bottom: parent.textFirst ? undefined : parent.bottom
        anchors.bottomMargin: parent.textFirst ? 0 : 30
        anchors.left: parent.left
        anchors.leftMargin: textLeftMargin
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
