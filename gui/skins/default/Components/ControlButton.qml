import QtQuick 1.1
import Components.Text 1.0


Image {
    id: control

    property string label: qsTr("FORCE LOAD")

    signal clicked

    height: 50
    source: "../images/common/bg_DueRegolazioni.png"
    anchors.fill: parent

    UbuntuLightText {
        id: textDescription

        anchors.fill: parent
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        text: control.label
    }

    BeepingMouseArea {
        id: areaHeader
        anchors.fill: parent
        onClicked: control.clicked()
    }
}
