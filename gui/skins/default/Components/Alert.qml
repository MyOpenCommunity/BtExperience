import QtQuick 1.1
import Components.Text 1.0


Column {
    id: alert

    property alias message: text.text
    property Item source: null

    signal closeAlert

    spacing: 4

    SvgImage {
        source: "../images/scenarios/bg_titolo.svg"

        UbuntuMediumText {
            text: qsTr("Warning")
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
            id: text
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 14
            color: "white"
            text: "Alert message goes here."
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
                    alert.source.alertOkClicked()
                    alert.source = null
                    alert.closeAlert()
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
                    if (alert.source.alertCancelClicked)
                        alert.source.alertCancelClicked()
                    alert.source = null
                    alert.closeAlert()
                }
            }
        }
    }
}



