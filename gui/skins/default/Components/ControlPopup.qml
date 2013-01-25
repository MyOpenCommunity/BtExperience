import QtQuick 1.1
import Components.Text 1.0


Column {
    id: control

    property alias title: title.text
    property alias line1: line1.text
    property alias line2: line2.text
    property alias line3: line3.text
    property alias confirmText: buttonConfirm.text
    property alias dismissText: buttonDismiss.text

    signal confirmClicked
    signal dismissClicked

    spacing: 4

    SvgImage {
        id: bgTitle

        source: "../images/scenarios/bg_titolo.svg"
        anchors.left: control.left

        UbuntuMediumText {
            id: title

            color: "white"
            font.pixelSize: 24
            text: "ANTINTRUSIONE"
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
                leftMargin: parent.width / 100 * 2.27
            }
            verticalAlignment: Text.AlignVCenter
        }
    }

    SvgImage {
        id: bgBody

        source: "../images/scenarios/bg_testo.svg"
        anchors.left: control.left

        UbuntuMediumText {
            id: line1

            color: "white"
            font.pixelSize: 18
            text: "Zona 4 'persiane'"
            anchors {
                centerIn: bgBody
                verticalCenterOffset: -bgTitle.height / 100 * 28.09
            }
        }

        UbuntuLightText {
            id: line2

            color: "white"
            font.pixelSize: 18
            text: "14:27 - 10/09/2012"
            anchors {
                centerIn: bgBody
                verticalCenterOffset: 0
            }
        }

        UbuntuLightText {
            id: line3

            color: "white"
            font.pixelSize: 18
            text: "Manomissione"
            anchors {
                centerIn: bgBody
                verticalCenterOffset: bgTitle.height / 100 * 28.09
            }
        }
    }

    SvgImage {
        id: bgBottom

        source: "../images/scenarios/bg_ok_annulla.svg"
        anchors.left: control.left

        ButtonThreeStates {
            id: buttonDismiss
            visible: buttonDismiss.text !== ""
            defaultImage: "../images/common/btn_150x35.svg"
            pressedImage: "../images/common/btn_150x35.svg"
            selectedImage: "../images/common/btn_150x35.svg"
            shadowImage: "../images/common/btn_shadow_150x35.svg"
            text: qsTr("dismiss")
            font.capitalization: Font.AllUppercase
            font.pixelSize: 14
            onClicked: dismissClicked()
            anchors {
                right: bgBottom.right
                rightMargin: bgTitle.width / 100 * 1.59
                bottom: bgBottom.bottom
                bottomMargin: bgTitle.height / 100 * 11.24
            }
        }

        ButtonThreeStates {
            id: buttonConfirm
            defaultImage: "../images/common/btn_150x35.svg"
            pressedImage: "../images/common/btn_150x35.svg"
            selectedImage: "../images/common/btn_150x35.svg"
            shadowImage: "../images/common/btn_shadow_150x35.svg"
            text: qsTr("confirm")
            font.capitalization: Font.AllUppercase
            font.pixelSize: 14
            onClicked: confirmClicked()
            anchors {
                right: buttonDismiss.visible ? buttonDismiss.left : bgBottom.right
                rightMargin: buttonDismiss.visible ? 0 : bgTitle.width / 100 * 1.59
                bottom: bgBottom.bottom
                bottomMargin: bgTitle.height / 100 * 11.24
            }
        }
    }
}
