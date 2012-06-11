import QtQuick 1.1
import Components.Text 1.0


Item {
    id: control

    width: 145
    height: 80

    property string title: "VOLUME"
    property int value: 50

    signal minusClicked
    signal plusClicked

    UbuntuLightText {
        id: title
        width: parent.width
        text: control.title
        color: "white"
        anchors.top: parent.top
    }

    Image {
        source: "../images/common/btn_comando.png"
        width: parent.width
        height: 70 / 80 * control.height
        anchors.top: title.bottom

        Image {
            width: parent.width - 10
            height: 20 / 80 * control.height
            anchors {
                top: parent.top
                leftMargin: 4
                rightMargin: 4
                topMargin: 4
                horizontalCenter: parent.horizontalCenter
            }
            source: "../images/common/bg_volume.png"

            Image {
                source: "../images/common/dimmer_reg.png"
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 1
                width: parent.width * control.value / 100 - 1
                height: parent.height - 2
            }
        }

        ButtonMinusPlus {
            width: parent.width - 10
            height: 35 / 80 * control.height
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
                bottomMargin: 4
                leftMargin: 4
                rightMargin: 4
            }
            onPlusClicked: control.plusClicked()
            onMinusClicked: control.minusClicked()
        }
    }
}
