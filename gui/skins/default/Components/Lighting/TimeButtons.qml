import QtQuick 1.0

Image {
    id: timeButtons
    source: "../../images/common/btn_indietro.png"
    width: 80
    height: 100

    property alias measureUnit: units.text
    property int value: 5

    signal plusClicked
    signal minusClicked

    Column {
        anchors.fill: parent
        Image {
            id: plusButton
            source: "../../images/common/btn_annulla.png"
            width: parent.width
            height: 24

            UbuntuLightText {
                text: "+"
                anchors.centerIn: parent
            }

            MouseArea {
                anchors.fill: parent
                onClicked: plusClicked()
            }
        }

        Item {
            width: parent.width
            height: timeButtons.height - plusButton.height * 2
            UbuntuLightText {
                id: numberText
                text: timeButtons.value
                color: "#5b5b5b"
                font.pointSize: 18
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }

            UbuntuLightText {
                id: units
                text: "hours"
                color: "#5b5b5b"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: numberText.bottom
            }
        }

        Image {
            id: minusButton
            source: "../../images/common/btn_annulla.png"
            width: parent.width
            height: 24

            UbuntuLightText {
                text: "-"
                anchors.centerIn: parent
            }

            MouseArea {
                anchors.fill: parent
                onClicked: minusClicked()
            }
        }
    }
}
