import QtQuick 1.1

Row {
    id: button
    property bool status: false
    signal clicked (bool newStatus)
    Image {
        id: imgOn
        source: "common/btn_OKAnnulla.png"
        width: 104
        height: 50
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
        source: "common/btn_OKAnnullaS.png"
        width: 104
        height: 50

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
        PropertyChanges { target: imgOn; source: "common/btn_OKAnnullaS.png"; textColor: "#ffffff"; }
        PropertyChanges { target: imgOff; source: "common/btn_OKAnnulla.png"; textColor: "#000000"; }
    }
}

