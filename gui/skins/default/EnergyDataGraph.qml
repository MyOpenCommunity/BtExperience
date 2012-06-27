import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Text 1.0
import Components.EnergyManagement 1.0

import "js/Stack.js" as Stack


Page {
    property variant energyItem: undefined

    function systemsButtonClicked() {
        Stack.showPreviousPage(1)
    }

    showSystemsButton: true
    text: qsTr("energy consumption")
    source: "images/bg2.jpg"

    QtObject {
        id: privateProps
        property bool showCurrency: false
        // TODO: make the date change possible!
        property int graphType: EnergyData.CumulativeMonthGraph
        property date graphDate: new Date(2011, 4, 15)
        property variant modelGraph: energyItem.getGraph(graphType, graphDate, EnergyData.Consumption)
    }

    SvgImage {
        id: header
        source: "images/energy/bg_titolo.svg"
        anchors {
            top: navigationBar.top
            left: parent.left
            leftMargin: 130
        }

        SvgImage {
            source: "images/energy/ico_electricity_bianca.svg"
            anchors {
                verticalCenter: parent.verticalCenter
                right: titleText.left
                rightMargin: 5
            }
        }

        UbuntuLightText {
            id: titleText
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: parent.width / 100 * 5
            }

            font.pixelSize: 24
            text: translations.get("ENERGY_TYPE", energyItem.energyType)
            color: "white"
        }
    }

    Row {
        spacing: 4
        anchors {
            top: header.bottom
            topMargin: 4
            left: header.left
        }

        SvgImage {
            source: "images/energy/bg_grafico_time.svg"

            Row {
                id: timeButtonRow
                anchors {
                    top: buttonRow.top
                    left: divisorLine.left
                    leftMargin: divisorLine.width / 100 * 17
                }

                UbuntuLightText {
                    text: "time"
                    color: "white"
                    anchors.verticalCenter: dayButton.verticalCenter
                    font.pixelSize: 14
                }
                Item {
                    width: 15
                    height: dayButton.height
                }
                ButtonThreeStates {
                    id: dayButton
                    defaultImage: "images/energy/btn_time.svg"
                    pressedImage: "images/energy/btn_time_P.svg"
                    selectedImage: "images/energy/btn_time_S.svg"
                    shadowImage: "images/energy/ombra_btn_time.svg"
                    text: qsTr("day")
                    status: 0
                    onClicked: {}
                }
                ButtonThreeStates {
                    id: monthButton
                    defaultImage: "images/energy/btn_time.svg"
                    pressedImage: "images/energy/btn_time_P.svg"
                    selectedImage: "images/energy/btn_time_S.svg"
                    shadowImage: "images/energy/ombra_btn_time.svg"
                    text: qsTr("month")
                    status: 1
                    onClicked: {}
                }
                ButtonThreeStates {
                    id: yearButton
                    defaultImage: "images/energy/btn_time.svg"
                    pressedImage: "images/energy/btn_time_P.svg"
                    selectedImage: "images/energy/btn_time_S.svg"
                    shadowImage: "images/energy/ombra_btn_time.svg"
                    text: qsTr("year")
                    status: 0
                    onClicked: {}
                }
            }

            Row {
                id: buttonRow
                anchors {
                    top: parent.top
                    topMargin: parent.height / 100 * 3
                    right: divisorLine.right
                }

                UbuntuLightText {
                    text: "value"
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
                    status: privateProps.showCurrency === false ? 1 : 0
                    onClicked: privateProps.showCurrency = false
                }
            }

            SvgImage {
                id: divisorLine
                source: "images/energy/linea_grafico.svg"
                anchors {
                    top: buttonRow.bottom
                    topMargin: parent.height / 100 * 3
                    horizontalCenter: parent.horizontalCenter
                }
            }


            Loader {
                id: pageContent
                anchors {
                    top: divisorLine.bottom
                    topMargin: parent.height * 0.1
                    left: divisorLine.left
                }

                sourceComponent: Component {
                    EnergyMonthGraph {
                        modelGraph: privateProps.modelGraph
                    }
                }
            }



        }

        SvgImage {
            source: "images/energy/bg_grafico_consumption.svg"

            EnergyDateSelector {
                anchors {
                    top: parent.top
                    topMargin: parent.height / 100 * 3
                    horizontalCenter: parent.horizontalCenter
                }
                label: "month"

            }
        }
    }

    EnergyManagementNames {
        id: translations
    }
}
