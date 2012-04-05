import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuElement {
    id: element
    height: 50 * itemList.count
    width: 212

    onChildDestroyed: itemList.currentIndex = -1

    ListView {
        id: itemList
        anchors.fill: parent
        currentIndex: -1
        interactive: false

        delegate: MenuItemDelegate {
            function getDescription() {
                if (itemObject.objectId === ObjectInterface.IdThermalControlledProbe) {
                    var descr = itemObject.temperature / 10 + qsTr("°C") + " ";
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
            hasChild: true
            onClicked: {
                element.loadElement(modelList.getComponentFile(itemObject.objectId), itemObject.name,
                                    modelList.getObject(model.index))
            }
        }

        model: modelList

        ObjectModel {
            id: modelList
            filters: [{objectId: ObjectInterface.IdThermalControlUnit99},
                      {objectId: ObjectInterface.IdThermalControlledProbe}]
        }
    }

}

