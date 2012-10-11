import QtQuick 1.1
import Components 1.0
import Components.Text 1.0
import Components.EnergyManagement 1.0


import "js/Stack.js" as Stack

Page {
    function systemsButtonClicked() {
        Stack.backToSystemOrHome()
    }

    function backButtonClicked() {
        Stack.backToPage("EnergyManagement.qml")
    }

    showSystemsButton: true
    text: qsTr("energy consumption")
    source: "images/bg2.jpg"


    QtObject {
        id: privateProps
        property bool showCurrency: false
    }

    SvgImage {
        id: header
        source: "images/energy/bg_titolo.svg"
        anchors {
            top: navigationBar.top
            left: parent.left
            leftMargin: 130
        }

        UbuntuLightText {
            id: titleText
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: parent.width / 100 * 5
            }

            font.pixelSize: 28
            text: qsTr("Global View")
            color: "white"
        }
    }

    SvgImage {
        id: bg_graph
        source: "images/energy/bg_grafico.svg"
        anchors {
            top: header.bottom
            topMargin: 4
            left: header.left
        }

        Row {
            id: buttonRow
            anchors {
                top: parent.top
                topMargin: parent.height / 100 * 3
                right: divisorLine.right
            }

            UbuntuLightText {
                text: qsTr("value")
                color: "white"
                anchors.verticalCenter: moneyButton.verticalCenter
                font.pixelSize: 14
            }

            Item {
                width: 15
                height: moneyButton.height
            }

            ButtonThreeStates {
                id: moneyButton
                defaultImage: "images/energy/btn_value.svg"
                pressedImage: "images/energy/btn_value_P.svg"
                selectedImage: "images/energy/btn_value_S.svg"
                shadowImage: "images/energy/ombra_btn_value.svg"
                text: qsTr("€")
                font.pixelSize: 14
                status: privateProps.showCurrency === true ? 1 : 0
                onClicked: privateProps.showCurrency = true
            }
            ButtonThreeStates {
                id: consumptionButton
                defaultImage: "images/energy/btn_value.svg"
                pressedImage: "images/energy/btn_value_P.svg"
                selectedImage: "images/energy/btn_value_S.svg"
                shadowImage: "images/energy/ombra_btn_value.svg"
                text: qsTr("units")
                font.pixelSize: 14
                status: privateProps.showCurrency === false ? 1 : 0
                onClicked: privateProps.showCurrency = false
            }
        }

        SvgImage {
            id: divisorLine
            source: "images/energy/linea.svg"
            anchors {
                top: buttonRow.bottom
                topMargin: parent.height / 100 * 3
                horizontalCenter: parent.horizontalCenter
            }
        }

        GlobalViewTable {
            anchors {
                top: divisorLine.bottom
                topMargin: 15
                horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
