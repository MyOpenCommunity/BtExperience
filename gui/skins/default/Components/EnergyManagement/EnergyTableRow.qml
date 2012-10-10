import QtQuick 1.1
import Components 1.0
import Components.Text 1.0


Row {
    id: tableRow
    property string index
    property string value
    spacing: 5
    height: 24

    Item {
        width: 95
        height: parent.height
        UbuntuLightText {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 10
            text: tableRow.index
            font.pixelSize: 14
            color: "white"
        }
    }

    Item {
        width: 75
        height: parent.height
        UbuntuLightText {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 10
            text: tableRow.value
            font.pixelSize: 14
            color: "white"
        }
    }
}
