import QtQuick 1.1
import Components 1.0
import Components.Text 1.0


Image {
    id: popupBg

    signal closePopup

    width: 212
    height: 200
    source: "../../images/common/bg_UnaRegolazione.png"

    Column {
        id: popup

        Item {
            width: parent.width
            height: 30
            UbuntuMediumText {
                text: qsTr("disable for")
                anchors {
                    centerIn: parent
                    verticalCenterOffset: 2
                }
            }
        }
        Item {
            width: parent.width
            height: 50
            UbuntuMediumText {
                text: qsTr("120")
                color: "white"
                anchors {
                    centerIn: parent
                }
                font.pixelSize: 48
            }
        }
        Item {
            width: parent.width
            height: 20
            UbuntuMediumText {
                text: qsTr("minutes")
                color: "white"
                anchors {
                    centerIn: parent
                    verticalCenterOffset: -5
                    topMargin: 0
                }
            }
        }
        ButtonMinusPlus {
        }
        ButtonOkCancel {
            onOkClicked: closePopup()
            onCancelClicked: closePopup()
        }
    }
}
