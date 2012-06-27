import QtQuick 1.1
import Components 1.0

MenuColumn {
    id: column

    onChildDestroyed: {
        paginator.currentIndex = -1
    }

    PaginatorList {
        id: paginator

        delegate: MenuItemDelegate {
            itemObject: modelList.get(index)
            status: -1
            name: model.name
            hasChild: true
            onClicked: column.loadColumn(itemObject.component, itemObject.name)
        }

        model: modelList
        onCurrentPageChanged: column.closeChild()
    }

    ListModel {
        id: modelList
        Component.onCompleted: {
            modelList.append({"name": qsTr("Thermal Regulator"), "component": thermalRegulator})
            modelList.append({"name": qsTr("Air Conditioning"), "component": airConditioning})
            modelList.append({"name": qsTr("Not Controlled Probes"), "component": notControlledProbes})
            modelList.append({"name": qsTr("External Probes"), "component": externalProbes})
        }
    }

    Component {
        id: thermalRegulator
        ThermalRegulator {}
    }

    Component {
        id: airConditioning
        AirConditioning {}
    }

    Component {
        id: notControlledProbes
        NotControlledProbes {}
    }

    Component {
        id: externalProbes
        ExternalProbes {}
    }
}
