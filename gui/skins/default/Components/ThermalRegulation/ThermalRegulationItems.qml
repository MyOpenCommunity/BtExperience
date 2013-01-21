import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import "../../js/array.js" as Script


MenuColumn {
    id: column

    Component { id: thermalRegulator; ThermalRegulator {} }
    Component { id: airConditioning; AirConditioning {} }
    Component { id: notControlledProbes; NotControlledProbes {} }
    Component { id: externalProbes; ExternalProbes {} }

    onChildDestroyed: {
        paginator.currentIndex = -1
    }

    ObjectModel {
        id: modelCU
        filters: [
            {objectId: ObjectInterface.IdThermalControlUnit99},
            {objectId: ObjectInterface.IdThermalControlUnit4}
        ]
    }

    PaginatorList {
        id: paginator

        delegate: MenuItemDelegate {
            itemObject: modelList.get(index)
            status: -1
            name: model.name
            hasChild: true
            onClicked: {
                if (itemObject.type === "object")
                    column.loadColumn(itemObject.component, itemObject.name, itemObject.object)
                else
                    column.loadColumn(itemObject.component, itemObject.name)
            }
        }

        model: modelList
        onCurrentPageChanged: column.closeChild()
    }

    QtObject {
        // the range property is defined here because we need the onRangeChanged
        // manager to recalculate the model
        id: props

        property variant range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)

        onRangeChanged: modelList.calculatePagedModel()
    }

    ListModel {
        id: modelList

        // pagination can work only if it knows the total count of elements
        property int count: 0

        function calculatePagedModel() {
            // recomputes the model to contain only elements belonging to range
            modelList.clear()
            for (var i = props.range[0]; i < props.range[1]; i++) {
                var obj = Script.container[i]
                if (obj) // on last page we may have some missing elements
                    modelList.append(obj)
            }
        }

        Component.onCompleted: {
            // adds CUs
            for (var i = 0; i < modelCU.count; i++)
                Script.container[i] = {"name": modelCU.getObject(i).name, "component": thermalRegulator, "object": modelCU.getObject(i), "type": "object"}
            // adds additional menus (not contained in the ObjectModel)
            Script.container[modelCU.count] = {"name": qsTr("Air Conditioning"), "component": airConditioning, "type": "component"}
            Script.container[modelCU.count + 1] = {"name": qsTr("Not Controlled Probes"), "component": notControlledProbes, "type": "component"}
            Script.container[modelCU.count + 2] = {"name": qsTr("External Probes"), "component": externalProbes, "type": "component"}
            // count must be equal to total elements, not number of elements contained in the model (for pagination)
            count = modelCU.count + 3
            calculatePagedModel()
        }
    }
}
