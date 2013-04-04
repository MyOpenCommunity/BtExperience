import QtQuick 1.1
import Components 1.0
import Components.Text 1.0


Column {
    id: tableHeader
    property string label
    property string unitMeasure

    Row {
        id: row
        spacing: 5
        height: 28

        Rectangle {
            color: "#e6e6e6"
            width: 95
            height: parent.height
            UbuntuLightText {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.right: parent.right
                anchors.rightMargin: 10
                font.pixelSize: 14
                text: tableHeader.label
                horizontalAlignment: Text.AlignHCenter
            }
        }

        Rectangle {
            color: "#e6e6e6"
            width: 95
            height: parent.height
            UbuntuLightText {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.right: parent.right
                anchors.rightMargin: 10
                font.pixelSize: 14
                text: tableHeader.unitMeasure
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
    Item {
        height: 10
        width: row.width
    }
}

