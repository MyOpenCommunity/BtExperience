/*
 * Copyright © 2011-2013 BTicino S.p.A.
 *
 * This file is part of BtExperience.
 *
 * BtExperience is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BtExperience is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BtExperience. If not, see <http://www.gnu.org/licenses/>.
 */

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

    SystemsModel { id: idThermalRegulationSystem; systemId: Container.IdThermalRegulation }
    SystemsModel { id: idAirConditioningSystem; systemId: Container.IdAirConditioning }

    ObjectModel {
        id: modelCU
        filters: [
            {objectId: ObjectInterface.IdThermalControlUnit99},
            {objectId: ObjectInterface.IdThermalControlUnit4}
        ]
        containers: [idThermalRegulationSystem.systemUii]
    }

    ObjectModel {
        id: airConditioningModel
        filters: [
            {objectId: ObjectInterface.IdSplitBasicScenario},
            {objectId: ObjectInterface.IdSplitAdvancedScenario}
        ]
        containers: [idAirConditioningSystem.systemUii]
    }

    ObjectModel {
        id: notCotrolledProbesModel
        filters: [
            {objectId: ObjectInterface.IdThermalNonControlledProbe}
        ]
        containers: [idThermalRegulationSystem.systemUii]
    }

    ObjectModel {
        id: externalProbesModel
        filters: [
            {objectId: ObjectInterface.IdThermalExternalProbe}
        ]
        containers: [idThermalRegulationSystem.systemUii]
    }

    PaginatorList {
        id: paginator

        delegate: MenuItemDelegate {
            itemObject: modelList.get(index)
            status: -1
            name: model.name
            hasChild: true
            onDelegateTouched: {
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
            var offset = 0
            if (airConditioningModel.count > 0) {
                Script.container[modelCU.count + offset] = {"name": qsTr("Air Conditioning"), "component": airConditioning, "type": "component"}
                offset += 1
            }
            if (notCotrolledProbesModel.count > 0) {
                Script.container[modelCU.count + offset] = {"name": qsTr("Non-Controlled Probes"), "component": notControlledProbes, "type": "component"}
                offset += 1
            }
            if (externalProbesModel.count > 0) {
                Script.container[modelCU.count + offset] = {"name": qsTr("External Probes"), "component": externalProbes, "type": "component"}
                offset += 1
            }
            // count must be equal to total elements, not number of elements contained in the model (for pagination)
            count = modelCU.count + offset
            calculatePagedModel()
        }
    }
}
