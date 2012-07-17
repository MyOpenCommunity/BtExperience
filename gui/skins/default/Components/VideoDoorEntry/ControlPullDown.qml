/**
  * A control to implement a pull down menu.
  * It has two states:
  *     - up: the down arrow is visible
  *     - down: the up arrow is visible
  * It has a loader where to load components (the menu, tipically).
  */

import QtQuick 1.1


Item {
    id: control

    property alias text: theButton.text
    property variant menu
    property alias menuAnchors: menuLoader.anchors

    signal clicked

    ButtonTextImageThreeStates {
        id: theButton

        text: qsTr("Video settings")
        textColor: "black"
        onClicked: {
            control.state = (control.state === "up") ? "down" : "up"
            control.clicked()
        }
        defaultImageBg: "../../images/common/btn_impostazioni.svg"
        pressedImageBg: "../../images/common/btn_impostazioni_P.svg"
        defaultImage: "../../images/common/ico_apri_impostazioni.svg"
        pressedImage: "../../images/common/ico_apri_impostazioni_P.svg"
        shadowImage: "../../images/common/ombra_btn_impostazioni.svg"
        imageAnchors.rightMargin: 7
        anchors.top: parent.top
    }

    Loader {
        id: menuLoader

        anchors.top: theButton.bottom
    }

    state: "up"

    states: [
        State {
            name: "up"
            extend: ""
        },
        State {
            name: "down"
            PropertyChanges {
                target: theButton
                defaultImage: "../../images/common/ico_chiudi_impostazioni.svg"
                pressedImage: "../../images/common/ico_chiudi_impostazioni.svg"
            }
            PropertyChanges {
                target: menuLoader
                sourceComponent: menu
            }
        }
    ]
}
