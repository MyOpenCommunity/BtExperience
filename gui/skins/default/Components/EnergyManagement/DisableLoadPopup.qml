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
            UbuntuLightText {
                text: qsTr("disable for")
                anchors {
                    centerIn: parent
                    verticalCenterOffset: 2
                }
                font {
                    family: semiBoldFont.name
                }
            }
        }
        Item {
            width: parent.width
            height: 50
            UbuntuLightText {
                text: qsTr("120")
                color: "white"
                anchors {
                    centerIn: parent
                }
                font {
                    family: semiBoldFont.name
                    pixelSize: 48
                    bold: true
                }
            }
        }
        Item {
            width: parent.width
            height: 20
            UbuntuLightText {
                text: qsTr("minutes")
                color: "white"
                anchors {
                    centerIn: parent
                    verticalCenterOffset: -5
                    topMargin: 0
                }
                font {
                    family: semiBoldFont.name
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
