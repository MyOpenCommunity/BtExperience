import QtQuick 1.1
import Components 1.0
import Components.Text 1.0

MenuColumn {
    id: column

    property bool dateVisible: true

    height: background.height
    width: background.width

    SvgImage {
        id: background
        source: "../../images/termo/comando_data-ora/bg_comando_data-ora.svg"

        UbuntuLightText {
            id: labelDate
            visible: column.dateVisible
            color: "black"
            text: qsTr("until date")
            font.pixelSize: 13
            anchors {
                top: parent.top
                topMargin: 5
                left: parent.left
                leftMargin: 7
            }
        }

        ControlDateTime {
            id: controlDate
            visible: column.dateVisible
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: labelDate.bottom
                topMargin: 7
            }
            itemObject: dataModel
            separator: "/"
            mode: 1
        }

        UbuntuLightText {
            id: labelTime
            color: "black"
            text: qsTr("until time")
            font.pixelSize: 13
            anchors {
                top: controlDate.bottom
                topMargin: 5
                left: parent.left
                leftMargin: 7
            }
        }

        ControlDateTime {
            id: controlTime
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: labelTime.bottom
                topMargin: 7
            }
            itemObject: dataModel
            mode: 0
            twoFields: true
        }
    }
}
