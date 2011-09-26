import QtQuick 1.1

Row {
    id: button
    signal plusClicked
    signal minusClicked
    Image {
        source: "common/piu_meno.png"
        width: 122
        height: 57
        Image {
            source: "common/meno.png"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
        }
        MouseArea {
            anchors.fill: parent
            onClicked: button.minusClicked()
        }
    }
    Image {
        source: "common/piu_meno.png"
        width: 122
        height: 57
        Image {
            source: "common/piu.png"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
        }
        MouseArea {
            anchors.fill: parent
            onClicked: button.plusClicked()
        }
    }
}

