import QtQuick 1.1
import Components 1.0
import Components.Text 1.0


Image {
    id: control
    width: 212
    height: 150
    source: "../../images/common/bg_DueRegolazioni.png"

    property alias title: title.text
    property alias text: label.text
    signal downClicked()
    signal upClicked()
    signal resetClicked()

    UbuntuLightText {
        id: title
        text: qsTr("title")
        anchors.top: parent.top
        anchors.topMargin: 5
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 15
    }

    UbuntuLightText {
        id: label
        x: 33
        y: 64
        color: "#ffffff"
        text: qsTr("label")
        anchors.left: parent.left
        anchors.leftMargin: 33
        font.pixelSize: 15
        wrapMode: Text.WordWrap
    }

    Row {
        anchors.right: parent.right
        anchors.rightMargin: 5
        anchors.bottom: resetButton.top
        anchors.bottomMargin: 5
        Image {
            id: up
            width: 43
            height: 45
            source: "../../images/common/btn_comando.png"

            Image {
                id: image7
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                source: "../../images/common/freccia_up.png"
            }

            BeepingMouseArea {
                id: mouse_area1
                anchors.fill: parent
                onClicked: control.upClicked()
            }
        }

        Image {
            id: down
            width: 43
            height: 45
            source: "../../images/common/btn_comando.png"

            Image {
                id: image8
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                source: "../../images/common/freccia_dw.png"
            }

            BeepingMouseArea {
                id: mouse_area2
                anchors.fill: parent
                onClicked: control.downClicked()
            }
        }
    }

    Image {
        id: resetButton
        anchors {
            bottom: parent.bottom
            bottomMargin: 5
            right: parent.right
            rightMargin: 5
            left: parent.left
            leftMargin: 5
        }
        source: "../../images/common/btn_OKAnnulla.png"

        UbuntuLightText {
            id: resetText
            text: qsTr("force reset")
            font.capitalization: Font.SmallCaps
            anchors.centerIn: parent
        }

        BeepingMouseArea {
            anchors.fill: parent
            onClicked: control.resetClicked()
        }
    }
}

