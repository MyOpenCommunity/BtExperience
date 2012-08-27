import QtQuick 1.1
import Components 1.0
import Components.Text 1.0
import BtObjects 1.0

MenuColumn {
    id: column
    Item {
        id: controls
        width: bg1.width
        height: bg1.height
        SvgImage {
            id: bg1
            source: "../../images/termo/comando_data-ora/bg_comando_data-ora.svg"
        }


        UbuntuLightText {
            id: labelThreshold1
            color: "black"
            text: qsTr("threshold 1")
            font.pixelSize: 13
            anchors {
                top: parent.top
                topMargin: parent.height / 100 * 2
                left: parent.left
                leftMargin: parent.width / 100 * 4
            }
        }

        ControlDoubleSpin {
            id: spinThreshold1
            leftText: "2"
            rightText: "20"
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: labelThreshold1.bottom
                topMargin: parent.height / 100 * 2
            }
        }

        UbuntuLightText {
            id: labelThreshold2
            color: "black"
            text: qsTr("threshold 2")
            font.pixelSize: 13
            anchors {
                top: spinThreshold1.bottom
                topMargin: parent.height / 100 * 2
                left: parent.left
                leftMargin: parent.width / 100 * 4
            }
        }

        ControlDoubleSpin {
            id: spinThreshold2
            leftText: "2"
            rightText: "95"
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: labelThreshold2.bottom
                topMargin: parent.height / 100 * 2
            }
        }
    }

    ButtonOkCancel {
        anchors {
            top: controls.bottom
            left: parent.left
            right: parent.right
        }

        onCancelClicked: column.closeColumn()
        onOkClicked: column.closeColumn()
    }

}
