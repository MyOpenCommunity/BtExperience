import QtQuick 1.1
import Components.Text 1.0

Column {
    id: textDialog

    property alias title: titleLabel.text
    property alias titleColor: titleLabel.color
    property alias text: bodyText.text

    signal closePopup

    function okClicked() {
    }

    function cancelClicked() {
    }

    spacing: 4

    SvgImage {
        source: "../images/scenarios/bg_titolo.svg"

        UbuntuMediumText {
            id: titleLabel
            text: qsTr("Scenario configuration")
            font.pixelSize: 24
            color: "white"
            anchors {
                left: parent.left
                leftMargin: parent.width / 100 * 2
                verticalCenter: parent.verticalCenter
            }
        }
    }

    SvgImage {
        source: "../images/scenarios/bg_testo.svg"

        UbuntuMediumText {
            id: bodyText
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 14
            color: "white"
            text: qsTr("If you didn't cancel the scenario, you will add \
                       actions to the pre-existing scenario. Press OK if you want to start scenario programming, \
                       CANCEL if you wish to abort the operation.")
            wrapMode: Text.Wrap
            anchors {
                right: parent.right
                rightMargin: parent.width / 100 * 2
                left: parent.left
                leftMargin: parent.width / 100 * 2
            }
        }
    }

    SvgImage {
        source: "../images/scenarios/bg_ok_annulla.svg"

        Row {
            anchors {
                right: parent.right
                rightMargin: parent.width / 100 * 2
                verticalCenter: parent.verticalCenter
            }

            ButtonThreeStates {
                defaultImage: "../images/common/btn_99x35.svg"
                pressedImage: "../images/common/btn_99x35_P.svg"
                selectedImage: "../images/common/btn_99x35_S.svg"
                shadowImage: "../images/common/btn_shadow_99x35.svg"
                text: qsTr("ok")
                font.pixelSize: 14
                onPressed: {
                    textDialog.okClicked()
                    textDialog.closePopup()
                }
            }

            ButtonThreeStates {
                defaultImage: "../images/common/btn_99x35.svg"
                pressedImage: "../images/common/btn_99x35_P.svg"
                selectedImage: "../images/common/btn_99x35_S.svg"
                shadowImage: "../images/common/btn_shadow_99x35.svg"
                text: qsTr("cancel")
                font.pixelSize: 14
                onPressed: {
                    textDialog.cancelClicked()
                    textDialog.closePopup()
                }
            }
        }
    }
}
