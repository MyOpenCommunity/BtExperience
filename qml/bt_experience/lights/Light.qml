import QtQuick 1.0

Item {
    Row {
        Image {
            source: "../common/on_off.png"
            Text {
                text: "ON"
                font.pixelSize: 16
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
        Image {
            source: "../common/on_offS.png"
            Text {
                text: "OFF"
                color: "#ffffff";
                font.pixelSize: 16
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
    }


}
