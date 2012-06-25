import QtQuick 1.1
import Components 1.0
import Components.Text 1.0

Row {
    // TODO: implements all the logics! :)
    property alias label: textLabel.text
    spacing: 4
    ButtonImageThreeStates {
        defaultImageBg: "../images/energy/btn_freccia.svg"
        pressedImageBg: "../images/energy/btn_freccia_P.svg"
        shadowImage: "../images/energy/ombra_btn_freccia.svg"

        defaultImage: "../images/common/ico_freccia_sx.svg"
        pressedImage: "../images/common/ico_freccia_sx_P.svg"
        onClicked: {}
    }

    SvgImage {
        source: "../../images/energy/btn_selectDMY.svg"

        UbuntuLightText {
            id: textLabel
            font.pixelSize: 14
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
            }
        }

        UbuntuLightText {
            font.pixelSize: 13
            text: "11/2011"
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: textLabel.bottom
                topMargin: 5
            }
        }

        SvgImage {
            anchors {
                left: parent.left
                top: parent.bottom
                right: parent.right
            }
            source: "../../images/energy/ombra_btn_selectDMY.svg"
        }
    }

    ButtonImageThreeStates {
        defaultImageBg: "../images/energy/btn_freccia.svg"
        pressedImageBg: "../images/energy/btn_freccia_P.svg"
        shadowImage: "../images/energy/ombra_btn_freccia.svg"

        defaultImage: "../images/common/ico_freccia_dx.svg"
        pressedImage: "../images/common/ico_freccia_dx_P.svg"
        onClicked: {}
    }
}
