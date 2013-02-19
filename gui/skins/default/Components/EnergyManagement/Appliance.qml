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
            ControlSwitch {
                visible: element.dataModel.hasControlUnit
                upperText: qsTr("Device")
                // the following test is "simplified" because the switch is
                // visible only if the load has a CU: if CU is not present
                // the switch is not visible
                text: privateProps.loadEnabled() ? qsTr("Controlled") : qsTr("Not Controlled")
                pixelSize: 14
                onPressed: privateProps.loadEnabled() && element.dataModel.loadForced ?
                               element.dataModel.stopForcing() :
                               element.dataModel.forceOn()
                status: !(privateProps.loadEnabled() && element.dataModel.loadForced)
            }

            ForceLoad {
                visible: element.dataModel.loadForced
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
            ControlSwitch {
                visible: element.dataModel.hasControlUnit
                upperText: qsTr("Device")
                // the following test is "simplified" because the switch is
                // visible only if the load has a CU: if CU is not present
                // the switch is not visible
                text: privateProps.loadEnabled() ? qsTr("Controlled") : qsTr("Not Controlled")
                pixelSize: 14
                onPressed: privateProps.loadEnabled() && element.dataModel.loadForced ?
                               element.dataModel.stopForcing() :
                               element.dataModel.forceOn()
                status: !(privateProps.loadEnabled() && element.dataModel.loadForced)
            }

            ForceLoad {
                visible: element.dataModel.loadForced
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

    QtObject {
        id: privateProps

        function loadEnabled() {
            return element.dataModel.hasControlUnit && element.dataModel.loadEnabled
        }
    }
}
