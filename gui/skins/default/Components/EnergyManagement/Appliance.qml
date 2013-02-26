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
            }
        }
    }

    Component {
        id: applianceWithoutCu

        Column {
            InstantConsumption {
                load: element.dataModel
                showCurrency: unitSelectorItem.showCurrency
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

                load: element.dataModel
            }

        }
    }

    Component {
        id: applianceAdvancedWithCu

        Column {
            ControlSwitchLoadManagement {
                loadWithCU: element.dataModel
            }

            InstantConsumption {
                load: element.dataModel
                showCurrency: unitSelectorItem.showCurrency
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

                load: element.dataModel
            }

        }
    }
}
