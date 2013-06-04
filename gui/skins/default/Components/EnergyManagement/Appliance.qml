import QtQuick 1.1
import BtObjects 1.0
import Components 1.0


MenuColumn {
    id: element

    AnimatedLoader {
        id: applianceLoader

        anchors.top: parent.top
        onItemChanged: {
            // TODO when loaded item changes menu height is not updated
            // this trick is to force height update
            if (item) {
                element.height = item.height
                element.width = item.width
            }
        }

        Component.onCompleted: {
            if (element.dataModel.hasControlUnit) {
                if (element.dataModel.hasConsumptionMeters) // advanced with CU
                    applianceLoader.setComponent(applianceAdvancedWithCu)
                else // base with CU
                    applianceLoader.setComponent(applianceBaseWithCu)
            }
            else { // no CU
                applianceLoader.setComponent(applianceWithoutCu)
            }
        }
    }

    Component {
        id: applianceBaseWithCu

        Column {
            ControlSwitchLoadManagement {
                loadWithCU: element.dataModel
                visible: element.dataModel.loadEnabled
            }

            SvgImage {
                source: "../../images/common/panel_212x50.svg"
                visible: !element.dataModel.loadEnabled

                ButtonThreeStates {
                    anchors.centerIn: parent
                    text: qsTr("Force the load")
                    defaultImage: "../../images/common/btn_apriporta_ok_on.svg"
                    pressedImage: "../../images/common/btn_apriporta_ok_on_P.svg"
                    selectedImage: "../../images/common/btn_apriporta_ok_on.svg"
                    shadowImage: "../../images/common/ombra_btn_apriporta_ok_on.svg"
                    onTouched: element.dataModel.forceOn()
                }
            }
        }
    }

    Component {
        id: applianceWithoutCu

        Column {
            InstantConsumption {
                load: element.dataModel
            }

            Partial {
                visible: element.dataModel.hasConsumptionMeters
                load: element.dataModel
                partialId: 0 // expects periodTotals are zero-based
                showCurrency: unitSelectorItem.showCurrency
            }

            Partial {
                visible: element.dataModel.hasConsumptionMeters
                load: element.dataModel
                partialId: 1
                showCurrency: unitSelectorItem.showCurrency
            }

            UnitSelector {
                id: unitSelectorItem

                visible: load.rate || false
                load: element.dataModel
            }

        }
    }

    Component {
        id: applianceAdvancedWithCu

        Column {
            ControlSwitchLoadManagement {
                loadWithCU: element.dataModel
                visible: element.dataModel.loadEnabled
            }

            SvgImage {
                source: "../../images/common/panel_212x50.svg"
                visible: !element.dataModel.loadEnabled

                ButtonThreeStates {
                    anchors.centerIn: parent
                    text: qsTr("Force the load")
                    defaultImage: "../../images/common/btn_apriporta_ok_on.svg"
                    pressedImage: "../../images/common/btn_apriporta_ok_on_P.svg"
                    selectedImage: "../../images/common/btn_apriporta_ok_on.svg"
                    shadowImage: "../../images/common/ombra_btn_apriporta_ok_on.svg"
                    onTouched: element.dataModel.forceOn()
                }
            }

            InstantConsumption {
                load: element.dataModel
            }

            Partial {
                visible: element.dataModel.hasConsumptionMeters
                load: element.dataModel
                partialId: 0 // expects periodTotals are zero-based
                showCurrency: unitSelectorItem.showCurrency
            }

            Partial {
                visible: element.dataModel.hasConsumptionMeters
                load: element.dataModel
                partialId: 1
                showCurrency: unitSelectorItem.showCurrency
            }

            UnitSelector {
                id: unitSelectorItem

                visible: load.rate || false
                load: element.dataModel
            }

        }
    }
}
