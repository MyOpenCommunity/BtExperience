import QtQuick 1.1

Row {
    id: button
    property int status: 0
    signal clicked (bool newStatus)
    Image {
        id: imgOn
        source: "../images/common/btn_OKAnnulla.png"
        width: 104
        height: 50
        property alias textColor: textOn.color
        Text {
            id: textOn
            text: qsTr("on")
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
        source: "../images/common/btn_OKAnnullaS.png"
        width: 104
        height: 50

        property alias textColor: textOff.color
        Text {
            id: textOff
            text: qsTr("off")
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
    anchors.horizontalCenter: parent.horizontalCenter
    states: [
        State {
            when: status === 1
            name: "on"
            PropertyChanges { target: imgOn; source: "../images/common/btn_OKAnnullaS.png"; textColor: "#ffffff"; }
            PropertyChanges { target: imgOff; source: "../images/common/btn_OKAnnulla.png"; textColor: "#000000"; }
        },
        State {
            when: status === -1
            name: "disabled"
            PropertyChanges { target: imgOn; source: "../images/common/btn_OKAnnulla.png"; textColor: "#000000"; }
            PropertyChanges { target: imgOff; source: "../images/common/btn_OKAnnulla.png"; textColor: "#000000"; }
        }
    ]
}

