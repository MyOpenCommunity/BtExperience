import QtQuick 1.1
import Components 1.0

Row {
    id: row
    property bool isPlayerMute: false

    signal muteClicked
    signal decrementVolume
    signal incrementVolume

    spacing: 3
    Item {
        // I used an Item to define some specific states for the buttonMute
        // please note that buttonMute is a ButtonImageThreeStates so it defines
        // its internal states, it is neither possible nor desirable to redefine
        // these internal states
        id: buttonMuteItem

        width: buttonMute.width
        height: buttonMute.height

        ButtonImageThreeStates {
            id: buttonMute

            defaultImageBg: "../../images/common/btn_45x35.svg"
            pressedImageBg: "../../images/common/btn_45x35_P.svg"
            shadowImage: "../../images/common/btn_shadow_45x35.svg"
            defaultImage: "../../images/common/ico_mute.svg"
            pressedImage: "../../images/common/ico_mute.svg"
            anchors.centerIn: parent

            onPressed: row.muteClicked()
        }

        state: row.isPlayerMute ? "mute" : ""

        states: [
            State {
                name: "mute"
                PropertyChanges {
                    target: buttonMute
                    defaultImage: "../../images/common/ico_mute_on.svg"
                    pressedImage: "../../images/common/ico_mute_on.svg"
                }
            }
        ]
    }

    Item {
        id: spacing
        height: 3
        width: 3
    }

    ButtonImageThreeStates {
        id: buttonMinus
        defaultImageBg: "../../images/common/btn_45x35.svg"
        pressedImageBg: "../../images/common/btn_45x35_P.svg"
        shadowImage: "../../images/common/btn_shadow_45x35.svg"
        defaultImage: "../../images/common/ico_meno.svg"
        pressedImage: "../../images/common/ico_meno_P.svg"
        onClicked: row.decrementVolume()
        repetitionOnHold: true
    }

    ButtonImageThreeStates {
        id: buttonPlus
        defaultImageBg: "../../images/common/btn_45x35.svg"
        pressedImageBg: "../../images/common/btn_45x35_P.svg"
        shadowImage: "../../images/common/btn_shadow_45x35.svg"
        defaultImage: "../../images/common/ico_piu.svg"
        pressedImage: "../../images/common/ico_piu_P.svg"
        onClicked: row.incrementVolume()
        repetitionOnHold: true
    }
}
