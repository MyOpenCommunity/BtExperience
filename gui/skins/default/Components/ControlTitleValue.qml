import QtQuick 1.1
import Components.Text 1.0


Item {
    id: control

    width: bg.width
    height: bg.height

    property string title
    property string value
    property bool readOnly: true
    property string inputMask

    signal accepted

    SvgImage {
        id: bg
        source: "../images/common/menu_column_item_bg.svg";
    }

    UbuntuLightText {
        text: control.title
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: control.top
        anchors.topMargin: 5
        font.pixelSize: 14
        color:  "#2d2d2d"
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
        UbuntuLightText {
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: control.value
            font.pixelSize: 14
            color:  "#626262"
        }
    }

    // TODO: we can do better, loading the TextInput only when the user clicks on
    // the input field.
    Component {
        id: editableLabelComponent
        UbuntuLightTextInput {
            text: control.value
            inputMask: control.inputMask
            horizontalAlignment: Text.AlignHCenter
            onAccepted: acceptValue()
            onActiveFocusChanged: if (!activeFocus) acceptValue()
            font.pixelSize: 14
            color:  "#626262"

            function acceptValue() {
                control.value = text
                control.accepted()
            }
        }
    }
}
