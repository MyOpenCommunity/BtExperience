import QtQuick 1.1
import Components.Text 1.0


Item {
    id: control

    width: bg.width
    height: bg.height

    property string title
    property string value
    property string inputMask

    signal modifyIp

    SvgImage {
        id: bg
        source: "../images/common/menu_column_item_bg.svg";
    }

    BeepingMouseArea {
        anchors.fill: parent
        onPressed: control.modifyIp()
    }

    UbuntuLightText {
        text: control.title
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: control.top
            topMargin: 5
        }
        elide: Text.ElideRight
        width: bg.width / 100 * 90
        font.pixelSize: 14
        color:  "#2d2d2d"
    }

    UbuntuLightText {
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: control.bottom
            bottomMargin: 5
        }
        elide: Text.ElideRight
        width: bg.width / 100 * 90
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: control.value
        font.pixelSize: 14
        color:  "#626262"
    }
}
