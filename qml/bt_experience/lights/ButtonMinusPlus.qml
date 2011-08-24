import QtQuick 1.0

Row {
    Image {
        source: "../common/piu_meno.png"
        Image {
            source: "../common/meno.png"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
        }
    }
    Image {
        source: "../common/piu_meno.png"
        Image {
            source: "../common/piu.png"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
        }
    }

}
