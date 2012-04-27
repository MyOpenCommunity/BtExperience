import QtQuick 1.1


Item {
    id: control

    width: 212
    height: 50

    property string title
    property string value
    property bool readOnly: true

    signal accepted

    SvgImage {
        anchors.fill: parent
        source: "../images/common/menu_column_item_bg.svg";
    }

    Text {
        text: control.title
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: control.top
        anchors.topMargin: 5
        font.family: lightFont.name
        font.pixelSize: 14
        color:  "#2d2d2d"
        font.bold: true
    }

    Text {
        text: control.value
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: control.bottom
        anchors.bottomMargin: 5
        visible: control.readOnly
        font.family: regularFont.name
        font.pixelSize: 14
        color:  "#626262"
    }

    // TODO creation of a TextInput takes a long time; create it dinamically
    // when needed
    TextInput {
        text: control.value
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: control.bottom
        anchors.bottomMargin: 5
        visible: !control.readOnly
        onAccepted: { control.value = text; control.accepted() }
        font.family: regularFont.name
        font.pixelSize: 14
        color:  "#626262"
    }
}
