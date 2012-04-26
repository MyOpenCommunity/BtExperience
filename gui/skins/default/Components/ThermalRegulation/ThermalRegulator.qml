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
        listHeight: 50 * modelList.size
        currentIndex: -1

        delegate: MenuItemDelegate {
            function isControlledProbe() {
                return itemObject.objectId === ObjectInterface.IdThermalControlledProbe
            }

            function getDescription() {
                if (isControlledProbe()) {
                    if (itemObject.probeStatus === ThermalControlledProbe.Manual)
                        descr += itemObject.setpoint / 10 + qsTr("°C") + " ";

                    descr += pageObject.names.get('PROBE_STATUS', itemObject.probeStatus);
                    return descr;
                }
                else
                    return ''
            }

            itemObject: modelList.getObject(index)
            description: getDescription()
            boxInfoState: isControlledProbe() ? "info" : ""
            boxInfoText: isControlledProbe() ? itemObject.temperature / 10 + qsTr("°C") : ""
            hasChild: true
            onClicked: {
                column.loadColumn(
                            modelList.getComponent(itemObject.objectId),
                            itemObject.name,
                            modelList.getObject(model.index))
            }
        }

        model: modelList

        ObjectModel {
            id: modelList
            filters: [{objectId: ObjectInterface.IdThermalControlUnit99},
                      {objectId: ObjectInterface.IdThermalControlledProbe}]
        }

        onCurrentPageChanged: column.closeChild()
    }
}

