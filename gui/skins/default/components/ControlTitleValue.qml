import QtQuick 1.1


Image {
    id: control
    width: 212
    height: 50
    // TODO find a right background
    source: "../images/common/bg_volume.png"

    property string title
    property string value
    property bool readOnly: true

    signal accepted

    Text {
        text: control.title
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 16
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: control.top
        anchors.topMargin: 5
    }

    Text {
        text: control.value
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 16
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: control.bottom
        anchors.bottomMargin: 5
        visible: control.readOnly
    }

    TextInput {
        text: control.value
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 16
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: control.bottom
        anchors.bottomMargin: 5
        visible: !control.readOnly
        onAccepted: { control.value = text; control.accepted() }
    }
}
