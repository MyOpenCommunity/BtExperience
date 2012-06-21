import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: column

    onChildDestroyed: itemList.currentIndex = -1

    width: 212
    height: 250

    PaginatorList {
        id: itemList
        currentIndex: -1

        delegate: MenuItemDelegate {
            function isControlledProbe() {
                return (itemObject.objectId === ObjectInterface.IdThermalControlledProbe ||
                        itemObject.objectId === ObjectInterface.IdThermalControlledProbeFancoil)
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
            onClicked: column.loadColumn(mapping.getComponent(itemObject.objectId), itemObject.name, itemObject)
        }

        model: modelList
        onCurrentPageChanged: column.closeChild()
    }

    BtObjectsMapping { id: mapping }

    ObjectModel {
        id: modelList
        filters: [
            {objectId: ObjectInterface.IdThermalControlUnit99},
            {objectId: ObjectInterface.IdThermalControlUnit4},
            {objectId: ObjectInterface.IdThermalControlledProbe},
            {objectId: ObjectInterface.IdThermalControlledProbeFancoil}
        ]
    }
}

