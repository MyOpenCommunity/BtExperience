import QtQuick 1.1

Row {
    id: button
    property bool status: false
    signal clicked (bool newStatus)
    Image {
        id: imgOn
        source: "common/on_off.png"
        width: 122
        height: 65
        property alias textColor: textOn.color
        Text {
            id: textOn
            text: "ON"
            font.pixelSize: 18
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }
        MouseArea {
            anchors.fill: parent
            onClicked: button.clicked(true)
        }
    }
    Image {
        id: imgOff
        source: "common/on_offS.png"
        width: 122
        height: 65

        property alias textColor: textOff.color
        Text {
            id: textOff
            text: "OFF"
            color: "#ffffff";
            font.pixelSize: 18
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }
        MouseArea {
            anchors.fill: parent
            onClicked: button.clicked(false)
        }
    }
    anchors.top: parent.top
    anchors.horizontalCenter: parent.horizontalCenter
    states: State {
        when: status == true
        name: "on"
        PropertyChanges { target: imgOn; source: "common/on_offS.png"; textColor: "#ffffff"; }
        PropertyChanges { target: imgOff; source: "common/on_off.png"; textColor: "#000000"; }
    }
}

