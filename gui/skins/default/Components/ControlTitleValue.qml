import QtQuick 1.1


Item {
    id: control

    width: bg.width
    height: bg.height

    property string title
    property string value
    property bool readOnly: true

    signal accepted

    SvgImage {
        id: bg
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

    Loader {
        id: valueLoader
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: control.bottom
        anchors.bottomMargin: 5
        sourceComponent: control.readOnly ? simpleLabelComponent : editableLabelComponent
    }

    Component {
        id: simpleLabelComponent
        Text {
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: control.value
            font.family: regularFont.name
            font.pixelSize: 14
            color:  "#626262"
        }
    }

    // TODO: we can do better, loading the TextInput only when the user clicks on
    // the input field.
    Component {
    id: editableLabelComponent
        TextInput {
            text: control.value
            horizontalAlignment: Text.AlignHCenter
            onAccepted: { control.value = text; control.accepted() }
            font.family: regularFont.name
            font.pixelSize: 14
            color:  "#626262"
        }
    }
}
