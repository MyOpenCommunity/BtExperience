import QtQuick 1.1
import BtObjects 1.0
import Components 1.0


Item {
    id: control

    property variant itemObject

    signal delegateClicked

    width: bg.width
    height: bg.height

    ButtonTextImageThreeStates {
        id: bg

        text: itemObject === undefined ? "" : itemObject.sender
        defaultImageBg: itemObject === undefined ? "../../images/common/btn_messaggio.svg" : (itemObject.isRead ? "../../images/common/btn_messaggio.svg" : "../../images/common/btn_messaggio_non_letto.svg")
        pressedImageBg: "../../images/common/btn_messaggio_P.svg"
        selectedImageBg: "../../images/common/btn_messaggio_S.svg"
        shadowImage: "../../images/common/ombra_btn_messaggio.svg"
        defaultImage: itemObject === undefined ? "../../images/common/ico_messaggio_letto.svg" : (itemObject.isRead ? "../../images/common/ico_messaggio_letto.svg" : "../../images/common/ico_messaggio_non_letto.svg")
        pressedImage: itemObject === undefined ? "../../images/common/ico_messaggio_letto.svg" : (itemObject.isRead ? "../../images/common/ico_messaggio_letto.svg" : "../../images/common/ico_messaggio_non_letto.svg")
        imageAnchors.right: undefined
        textAnchors.leftMargin: bg.width / 100 * 8.70

        onPressed: delegateClicked()
    }

    SvgImage {
        id: rightArrow

        anchors {
            right: bg.right
            rightMargin: bg.width / 100 * 2.49
            verticalCenter: bg.verticalCenter
        }
        source: "../../images/common/ico_apri_cartella.svg"

        // for the reasons behind normal state see ButtonThreeStates
        states: [
            State {
                name: "pressed"
                when: bg.state === "pressed"
                PropertyChanges { target: rightArrow; source: "../../images/common/ico_apri_cartella_P.svg" }
            },
            State {
                name: "selected"
                when: bg.state === "selected"
                PropertyChanges { target: rightArrow; source: "../../images/common/ico_apri_cartella.svg" }
            },
            State {
                name: "normal"
                when: { return true }
                PropertyChanges { target: rightArrow; source: "../../images/common/ico_apri_cartella.svg" }
            }
        ]
    }
}
