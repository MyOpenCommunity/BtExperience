import QtQuick 1.1

Image {
    id: control

    property string label: qsTr("FORCE LOAD")

    signal clicked

    height: 50
    source: "../images/common/bg_DueRegolazioni.png"
    anchors.fill: parent

    Text {
        id: textDescription

        anchors.fill: parent
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        text: control.label
    }

    MouseArea {
        id: areaHeader
        anchors.fill: parent
        onClicked: control.clicked()
    }
}
