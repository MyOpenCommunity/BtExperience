import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Text 1.0


MenuColumn {
    id: column

    ObjectModel {
        // this must stay here otherwise theModel cannot be constructed properly
        id: objectModel
        filters: [{objectId: ObjectInterface.IdMessages}]
    }

    MediaModel {
        id: theModel
        source: objectModel.getObject(0).messages
    }

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

        defaultImageBg: "../../images/common/btn_66x35.svg"
        pressedImageBg: "../../images/common/btn_66x35_P.svg"
        shadowImage: "../../images/common/btn_shadow_66x35.svg"
        defaultImage: "../../images/common/messaggio_ricevuto/ico_elimina.svg"
        pressedImage: "../../images/common/messaggio_ricevuto/ico_elimina_P.svg"
        anchors {
            bottom: imageBg.bottom
            bottomMargin: imageBg.height / 100 * 2.66
            right: imageBg.right
            rightMargin: imageBg.width / 100 * 2.83
        }

        onPressed: {
            theModel.remove(column.dataModel)
            column.closeColumn()
        }
    }

    ButtonImageThreeStates {
        id: replyButton

        defaultImageBg: "../../images/common/btn_66x35.svg"
        pressedImageBg: "../../images/common/btn_66x35_P.svg"
        shadowImage: "../../images/common/btn_shadow_66x35.svg"
        defaultImage: "../../images/common/messaggio_ricevuto/ico_rispondi.svg"
        pressedImage: "../../images/common/messaggio_ricevuto/ico_rispondi_P.svg"
        anchors {
            bottom: imageBg.bottom
            bottomMargin: imageBg.height / 100 * 2.66
            right: deleteButton.left
            rightMargin: imageBg.width / 100 * 2.83
        }

        onPressed: {
            console.log("reply pressed")
            column.closeColumn()
        }
    }
}
