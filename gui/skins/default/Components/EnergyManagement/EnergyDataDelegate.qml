import QtQuick 1.1
import Components 1.0
import Components.Text 1.0

Column {
    spacing: 5
    ButtonThreeStates {
        defaultImage: "../images/energy/btn_colonna_grafico.svg"
        pressedImage: "../images/energy/btn_colonna_grafico.svg"
        shadowImage: "../images/energy/ombra_btn_colonna_grafico.svg"

        Row {
            anchors {
                left: parent.left
                leftMargin: 10
                verticalCenter: parent.verticalCenter
            }
            spacing: 10
            SvgImage {
                source: "../../images/energy/ico_electricity.svg"
            }
            UbuntuLightText {
                font.pixelSize: 14
                text: "electricity"
                color: "#5A5A5A"
            }
        }
    }

    UbuntuLightText {
        font.pixelSize: 18
        text: qsTr("220 kw/h")
        anchors.horizontalCenter: parent.horizontalCenter
        color: "white"
    }

    Column {
        SvgImage {
            source: "../../images/energy/colonna.svg"
        }
        SvgImage {
            source: "../../images/energy/ombra_btn_colonna_grafico.svg"
        }
    }

    UbuntuLightText {
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 14
        text: "may 2012"
        color: "white"
    }

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        UbuntuLightText {
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 14
            text: qsTr("instant consumption")
            color: "white"
        }

        SvgImage {
            anchors.horizontalCenter: parent.horizontalCenter
            source: "../../images/energy/bg_instant_consumption.svg"

            UbuntuLightText {
                anchors.centerIn: parent
                font.pixelSize: 14
                text: "45 w"
            }
        }
    }
}
