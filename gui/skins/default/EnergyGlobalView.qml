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

        Image {
            id: prevArrow
            source: "images/common/freccia_sx.svg"
            anchors {
                right: table.left
                rightMargin: 20
                verticalCenter: parent.verticalCenter
            }

            BeepingMouseArea {
                id: mouseAreaSx
                anchors.fill: parent
                onClicked: table.scrollLeft()
            }

            states: [
                State {
                    name: "pressed"
                    when: mouseAreaSx.pressed === true
                    PropertyChanges {
                        target: prevArrow
                        source: "images/common/freccia_sx_P.svg"
                    }
                }
            ]
        }

        GlobalViewTable {
            id: table
            anchors {
                top: divisorLine.bottom
                topMargin: 15
                horizontalCenter: parent.horizontalCenter
            }
        }

        Image {
            id: nextArrow
            source: "images/common/freccia_dx.svg"
            anchors {
                left: table.right
                leftMargin: 20
                verticalCenter: parent.verticalCenter
            }

            BeepingMouseArea {
                id: mouseAreaDx
                anchors.fill: parent
                onClicked: table.scrollRight()
            }

            states: [
                State {
                    name: "pressed"
                    when: mouseAreaDx.pressed === true
                    PropertyChanges {
                        target: nextArrow
                        source: "images/common/freccia_dx_P.svg"
                    }
                }
            ]
        }

    }
}
