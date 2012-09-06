import QtQuick 1.1
import Components 1.0
import Components.Text 1.0


MenuColumn {
    id: column

    SvgImage {
        id: imageBg
        source: "../../images/common/bg_messaggio.svg"
    }

    UbuntuLightText {
        id: text

        font.pixelSize: 20

        text: column.dataModel.text
        anchors {
            top: imageBg.top
            topMargin: imageBg.height / 100 * 3.32
            left: imageBg.left
            leftMargin: imageBg.width / 100 * 2.83
            right: imageBg.right
            rightMargin: imageBg.width / 100 * 2.83
        }
    }

    ButtonImageThreeStates {
        id: deleteButton

        defaultImageBg: "../../images/common/messaggio_ricevuto/btn_elimina.svg"
        pressedImageBg: "../../images/common/messaggio_ricevuto/btn_elimina_P.svg"
        shadowImage: "../../images/common/messaggio_ricevuto/ombra_btn_elimina.svg"
        defaultImage: "../../images/common/messaggio_ricevuto/ico_elimina.svg"
        pressedImage: "../../images/common/messaggio_ricevuto/ico_elimina_P.svg"
        anchors {
            bottom: imageBg.bottom
            bottomMargin: imageBg.height / 100 * 2.66
            right: imageBg.right
            rightMargin: imageBg.width / 100 * 2.83
        }

        onClicked: {
            console.log("delete pressed")
            column.closeColumn()
        }
        status: 0
    }

    ButtonImageThreeStates {
        id: replayButton

        defaultImageBg: "../../images/common/messaggio_ricevuto/btn_elimina.svg"
        pressedImageBg: "../../images/common/messaggio_ricevuto/btn_elimina_P.svg"
        shadowImage: "../../images/common/messaggio_ricevuto/ombra_btn_elimina.svg"
        defaultImage: "../../images/common/messaggio_ricevuto/ico_rispondi.svg"
        pressedImage: "../../images/common/messaggio_ricevuto/ico_rispondi_P.svg"
        anchors {
            bottom: imageBg.bottom
            bottomMargin: imageBg.height / 100 * 2.66
            right: deleteButton.left
            rightMargin: imageBg.width / 100 * 2.83
        }

        onClicked: {
            console.log("replay pressed")
            column.closeColumn()
        }
        status: 0
    }
}
