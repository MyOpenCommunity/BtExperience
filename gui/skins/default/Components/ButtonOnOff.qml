import QtQuick 1.1

Row {
    id: button
    property int status: 0
    signal clicked (bool newStatus)
    SvgImage {
        id: imgOn
        source: "../images/common/button_background.svg"
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
    SvgImage {
        id: imgOff
        source: "../images/common/button_background_select.svg"

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
            PropertyChanges { target: imgOn; source: "../images/common/button_background_select.svg"; textColor: "#ffffff"; }
            PropertyChanges { target: imgOff; source: "../images/common/button_background.svg"; textColor: "#000000"; }
        },
        State {
            when: status === -1
            name: "disabled"
            PropertyChanges { target: imgOn; source: "../images/common/button_background.svg"; textColor: "#000000"; }
            PropertyChanges { target: imgOff; source: "../images/common/button_background.svg"; textColor: "#000000"; }
        }
    ]
}

