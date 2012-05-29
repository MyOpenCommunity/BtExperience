import QtQuick 1.1
import Components 1.0

SvgImage {
    id: control

    property variant itemObject: undefined
    property alias isEnabled: privateProps.enabled

    source: "../../images/common/panel_time.svg"

    Text {
        id: title
        color: "black"
        text: qsTr("timer")
        anchors.top: parent.top
        anchors.topMargin: 5
        anchors.left: parent.left
        anchors.leftMargin: 7
        font.pointSize: 10.5
    }

    QtObject {
        id: privateProps
        property bool enabled: true
    }

    ControlOnOff {
        id: enableDisable
        width: parent.width
        anchors.top: title.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        onText: qsTr("ENABLED")
        offText: qsTr("DISABLED")
        status: privateProps.enabled
        onClicked: privateProps.enabled = newStatus
    }

    ControlDateTimeLighting {
        id: timingButtons
        anchors.top: enableDisable.bottom
        anchors.topMargin: 9
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: privateProps.enabled
        itemObject: control.itemObject
    }
}

