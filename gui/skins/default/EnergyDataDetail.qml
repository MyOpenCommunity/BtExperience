import QtQuick 1.1
import Components 1.0
import Components.Text 1.0
import Components.EnergyManagement 1.0
import BtObjects 1.0

import "js/Stack.js" as Stack

Page {
    property int energyType: 0

    function systemsButtonClicked() {
        Stack.showPreviousPage(1)
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
            text: translations.get("ENERGY_TYPE", energyType)
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
            source: "images/energy/linea.svg"
            anchors {
                top: buttonRow.bottom
                topMargin: parent.height / 100 * 3
                horizontalCenter: parent.horizontalCenter
            }
        }

        ListView {
            id: columnView
            interactive: false
            anchors {
                bottom: parent.bottom
                bottomMargin: 20
                horizontalCenter: parent.horizontalCenter
            }
            orientation: ListView.Horizontal
            height: 315
            width: 700
            delegate: EnergyDataDelegate {
                id: delegate
                itemObject: energiesCounters.getObject(index)
                description: itemObject.general ? qsTr("Overall") : itemObject.name
                measureType: privateProps.showCurrency === true ? EnergyData.Currency : EnergyData.Consumption
                isOverview: false
                onHeaderClicked: Stack.openPage("EnergyDataGraph.qml", {"energyItem": itemObject})
            }
            spacing: 40
            model: energiesCounters
        }
    }

    EnergyManagementNames {
        id: translations
    }

    ObjectModel {
        id: energiesCounters
        filters: [{objectId: ObjectInterface.IdEnergyData, objectKey: "type:" + energyType}]
    }
}
