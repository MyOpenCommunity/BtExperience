import QtQuick 1.1
import Components 1.0
import Components.Lighting 1.0
import Components.Text 1.0


MenuColumn {
    id: column

    property alias twoFields: dateTime.twoFields

    height: background.height
    width: background.width

    SvgImage {
        id: background
        source: "../../images/common/date_panel_background.svg"

        UbuntuLightText {
            id: label
            text: twoFields ? qsTr("time") : qsTr("date")
            anchors.top: parent.top
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.leftMargin: 15
        }

        ControlPlusMinusDateTime {
            id: dateTime
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: label.bottom
            anchors.topMargin: 10
            leftLabel: twoFields ? qsTr("hour") : qsTr("day")
            centerLabel: twoFields ? qsTr("minute") : qsTr("month")
            rightLabel: qsTr("year")
            separator: "/"
        }
    }
}
