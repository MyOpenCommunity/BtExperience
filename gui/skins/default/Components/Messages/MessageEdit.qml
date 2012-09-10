import QtQuick 1.1
import Components 1.0
import Components.Text 1.0


MenuColumn {
    id: column

    SvgImage {
        id: imageBg
        source: "../../images/common/bg_nuovo_messaggio.svg"
    }

    SvgImage {
        id: textBg
        source: "../../images/common/bg_testo_messaggio.svg"
        anchors {
            bottom: imageBg.bottom
            bottomMargin: imageBg.height / 100 * 7.35
            left: imageBg.left
            leftMargin: imageBg.width / 100 * 1.53
        }
    }

    UbuntuMediumText {
        id: remainingCharacters

        font.pixelSize: 14

        text: "150/150"
        anchors {
            left: textBg.left
            bottom: textBg.top
            bottomMargin: 10
        }
    }

    ButtonImageThreeStates {
        id: sendButton

        defaultImageBg: "../../images/common/btn_invia_messaggio.svg"
        pressedImageBg: "../../images/common/btn_invia_messaggio_P.svg"
        selectedImageBg: "../../images/common/btn_invia_messaggio_S.svg"
        shadowImage: "../../images/common/ombra_btn_invia_messaggio.svg"
        defaultImage: "../../images/common/ico_invia_messaggio.svg"
        pressedImage: "../../images/common/ico_invia_messaggio_P.svg"
        selectedImage: "../../images/common/ico_invia_messaggio_P.svg"
        anchors {
            bottom: textBg.top
            bottomMargin: imageBg.height / 100 * 7.35
            right: imageBg.right
            rightMargin: imageBg.width / 100 * 1.53
        }

        onClicked: {
            console.log("send pressed")
            column.closeColumn()
        }
        status: 0
    }

    UbuntuMediumText {
        font.pixelSize: 18

        text: qsTr("A:")
        color: "white"
        anchors {
            top: sendButton.top
            right: sendButton.left
            rightMargin: imageBg.width / 100 * 2.76 + imageBg.width / 100 * 32.47 + imageBg.width / 100 * 2.76
        }
    }

    ControlPullDown {
        menu: senderMenu
        text: "-"

        anchors {
            // anchors are computed assuming that ControlPullDown dimension are
            // not well defined, so we have to anchor left/up
            top: sendButton.top
            left: sendButton.left
            leftMargin: -imageBg.width / 100 * 2.76 - imageBg.width / 100 * 32.47
        }
    }

    Component {
        id: senderMenu
        Rectangle {
            // TODO implement list of senders (when specifications will be available)
            color: "green"
            width: 212
            height: 35
        }
    }
}
