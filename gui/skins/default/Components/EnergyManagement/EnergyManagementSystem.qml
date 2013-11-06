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
import Components.EnergyManagement 1.0
import "../../js/navigationconstants.js" as NavigationConstants


MenuColumn {
    id: element
    width: 212
    height: Math.max(1, 50 * listModel.count)


    SystemsModel { id: supervisionUii; systemId: Container.IdSupervision }
    SystemsModel { id: loadControlUii; systemId: Container.IdLoadControl }

    ObjectModel {
        id: stopNGoModel
        source: myHomeModels.myHomeObjects
        containers: [supervisionUii.systemUii]
        filters: [
            {objectId: ObjectInterface.IdStopAndGo},
            {objectId: ObjectInterface.IdStopAndGoPlus},
            {objectId: ObjectInterface.IdStopAndGoBTest}
        ]
    }

    ObjectModel {
        id: loadDiagnosticModel
        source: myHomeModels.myHomeObjects
        containers: [supervisionUii.systemUii]
        filters: [
            {objectId: ObjectInterface.IdLoadDiagnostic}
        ]
    }

    ObjectModel {
        id: loadManagementModel
        source: myHomeModels.myHomeObjects
        containers: [loadControlUii.systemUii]
        filters: [
            {objectId: ObjectInterface.IdLoadWithControlUnit},
            {objectId: ObjectInterface.IdLoadWithoutControlUnit}
        ]
    }

    // needed for menu navigation
    function targetsKnown() {
        return {
            "Supervision": privateProps.openSupervisionMenu,
        }
    }

    QtObject {
        id: privateProps

        function openSupervisionMenu(navigationData) {
            return _openMenu(qsTr("System supervision"))
        }

        function _openMenu(name) {
            for (var i = 0; i < listModel.count; ++i) {
                var m = listModel.get(i)
                if (name === m.name) {
                    listView.currentIndex = i
                    element.loadColumn(m.component, m.name)
                    return NavigationConstants.NAVIGATION_FINISHED_OK
                }
            }
        }
    }

    onChildDestroyed: {
        listView.currentIndex = -1
    }

    ListView {
        id: listView
        interactive: false
        currentIndex: -1
        anchors.fill: parent
        delegate: MenuItemDelegate {
            name: model.name
            hasChild: true
            enabled: model.name === qsTr("load management") ? loadManagementModel.count > 0 : true
            onDelegateTouched: element.loadColumn(model.component, model.name)
        }
        model: listModel
    }

    ListModel {
        id: listModel
        Component.onCompleted: {
            if (stopNGoModel.count + loadDiagnosticModel.count > 0)
                listModel.append({"name": qsTr("System supervision"), "component": supervision})
            listModel.append({"name": qsTr("consumption/production"), "component": energyOverview})
            if (loadManagementModel.count > 0)
                listModel.append({"name": qsTr("load management"), "component": loadManagement})
        }
    }

    Component {
        id: supervision
        Supervision {}
    }

    Component {
        id: loadManagement
        LoadManagement {}
    }

    Component {
        id: energyOverview
        EnergyOverview {}
    }
}
