import QtQuick 1.1

Row {
    id: button
    signal plusClicked
    signal minusClicked
    Image {
        source: "common/btn_comando.png"
        width: 104
        height: 50
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
        source: "common/btn_comando.png"
        width: 104
        height: 50
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

