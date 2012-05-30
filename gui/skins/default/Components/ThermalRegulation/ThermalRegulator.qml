import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: column
    height: itemList.height
    width: 212

    onChildDestroyed: itemList.currentIndex = -1

    PaginatorList {
        id: itemList
        width: parent.width
        listHeight: 50 * modelList.count
        currentIndex: -1

        delegate: MenuItemDelegate {
            function isControlledProbe() {
                return itemObject.objectId === ObjectInterface.IdThermalControlledProbe
            }

            function getDescription() {
                var descr = ""
                if (isControlledProbe()) {
                    if (itemObject.probeStatus === ThermalControlledProbe.Manual)
                        descr += itemObject.setpoint / 10 + qsTr("°C") + " ";

                    descr += pageObject.names.get('PROBE_STATUS', itemObject.probeStatus);
                }
                return descr
            }

            itemObject: modelList.getObject(index)
            description: getDescription()
            boxInfoState: isControlledProbe() ? "info" : ""
            boxInfoText: isControlledProbe() ? itemObject.temperature / 10 + qsTr("°C") : ""
            hasChild: true
            onClicked: {
                var z = 99
                if(modelList.getObject(0).objectId === ObjectInterface.IdThermalControlUnit4)
                    z = 4
                column.loadColumn(
                            mapping.getComponent(itemObject.objectId),
                            itemObject.name,
                            modelList.getObject(model.index),
                            {"zones": z})
            }
        }

        model: modelList

        onCurrentPageChanged: column.closeChild()
    }

    BtObjectsMapping { id: mapping }

    FilterListModel {
        id: modelList
        // NOTE we can have only one ControlUnit; filters are defined to have
        // the ControlUnit as first element of the model, so we can investigate
        // it to know if we are in the case of 99 zones or 4 zones.
        filters: [
            {objectId: ObjectInterface.IdThermalControlUnit99},
            {objectId: ObjectInterface.IdThermalControlUnit4},
            {objectId: ObjectInterface.IdThermalControlledProbe}
        ]
    }
}

