import QtQuick 1.1
import BtObjects 1.0
import BtExperience 1.0
import Components 1.0
import "../../js/Stack.js" as Stack
import "../../js/MenuItem.js" as Script


MenuColumn {
    id: column

    onChildDestroyed: paginator.currentIndex = -1

    SystemsModel { id: airConditioningModel; systemId: Container.IdAirConditioning }
    SystemsModel { id: automationItemsModel; systemId: Container.IdAutomation }
    SystemsModel { id: lightsModel; systemId: Container.IdLights }
    SystemsModel { id: loadControlModel; systemId: Container.IdLoadControl }
    SystemsModel { id: scenariosModel; systemId: Container.IdScenarios }
    SystemsModel { id: supervisionModel; systemId: Container.IdSupervision }
    SystemsModel { id: thermalRegulationModel; systemId: Container.IdThermalRegulation }
    SystemsModel { id: videoDoorEntryModel; systemId: Container.IdVideoDoorEntry }

    ObjectModel {
        id: cuObjects
        filters: [
            {objectId: ObjectInterface.IdThermalControlUnit99},
            {objectId: ObjectInterface.IdThermalControlUnit4}
        ]
        containers: [thermalRegulationModel.systemUii]
    }

    ObjectModel {
        id: airConditioningObjects
        filters: [
            {objectId: ObjectInterface.IdSplitBasicScenario},
            {objectId: ObjectInterface.IdSplitAdvancedScenario},
            {objectId: ObjectInterface.IdSplitBasicGenericCommandGroup},
            {objectId: ObjectInterface.IdSplitAdvancedGenericCommandGroup}
        ]
        containers: [airConditioningModel.systemUii]
    }

    ObjectModel {
        id: controlledProbesObjects
        filters: [
            {objectId: ObjectInterface.IdThermalControlledProbe},
            {objectId: ObjectInterface.IdThermalControlledProbeFancoil}
        ]
        containers: [thermalRegulationModel.systemUii]
    }

    ObjectModel {
        id: notControlledProbesObjects
        filters: [
            {objectId: ObjectInterface.IdThermalNonControlledProbe}
        ]
        containers: [thermalRegulationModel.systemUii]
    }

    ObjectModel {
        id: externalProbesObjects
        filters: [
            {objectId: ObjectInterface.IdThermalExternalProbe}
        ]
        containers: [thermalRegulationModel.systemUii]
    }

    ObjectModel {
        id: stopNGoObjects
        containers: [supervisionModel.systemUii]
        filters: [
            {objectId: ObjectInterface.IdStopAndGo},
            {objectId: ObjectInterface.IdStopAndGoPlus},
            {objectId: ObjectInterface.IdStopAndGoBTest}
        ]
    }

    ObjectModel {
        id: loadDiagnosticObjects
        containers: [supervisionModel.systemUii]
        filters: [
            {objectId: ObjectInterface.IdLoadDiagnostic}
        ]
    }

    ObjectModel {
        id: loadManagementObjects
        containers: [loadControlModel.systemUii]
        filters: [
            {objectId: ObjectInterface.IdLoadWithControlUnit},
            {objectId: ObjectInterface.IdLoadWithoutControlUnit}
        ]
    }

    ObjectModel {
        // TODO pager element is empty: investigate
        id: vdeObjects
        containers: [videoDoorEntryModel.systemUii]
        filters: [{objectId: ObjectInterface.IdCCTV},
            {objectId: ObjectInterface.IdIntercom}/*,
            {objectId: ObjectInterface.IdPager}*/
        ]
    }

    ObjectModel {
        id: notFilteredObjects
        containers: [automationItemsModel.systemUii,
            lightsModel.systemUii,
            scenariosModel.systemUii
        ]
    }

    ObjectModel {
        id: splitCommandObjects
        filters: [
            {objectId: ObjectInterface.IdSplitBasicCommand},
            {objectId: ObjectInterface.IdSplitAdvancedCommand}
        ]
    }

    ObjectModelSource {
        id: objectModelSource
    }

    ObjectModel {
        id: objectModel
        source: objectModelSource.model
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    // Select all btobjects already present in the room. We want to avoid
    // adding the same object twice to a room, it's not allowed.
    MediaModel {
        id: roomObjects
        source: myHomeModels.objectLinks
        containers: [column.dataModel.uii]
    }

    PaginatorList {
        id: paginator

        elementsOnPage: elementsOnMenuPage
        delegate: MenuItemDelegate {
            itemObject: objectModel.getObject(index)
            enabled: !privateProps.objectInRoom(itemObject)
            selectOnClick: false
            description: Script.description(itemObject)
            onDelegateTouched: myHomeModels.createObjectLink(itemObject, column.dataModel.uii)
        }
        model: objectModel
    }

    QtObject {
        id: privateProps

        function objectInRoom(itemObject) {
            for (var i = 0; i < roomObjects.count; ++i)
                if (roomObjects.getObject(i).btObject === itemObject)
                    return true
            return false
        }

        function appendModel(model) {
            for (var i = 0; i < model.count; ++i) {
                var o = model.getObject(i)
                objectModelSource.append(o)
            }
        }
    }

    Component.onCompleted: {
        privateProps.appendModel(cuObjects)
        privateProps.appendModel(controlledProbesObjects)
        privateProps.appendModel(airConditioningObjects)
        privateProps.appendModel(notControlledProbesObjects)
        privateProps.appendModel(externalProbesObjects)
        privateProps.appendModel(stopNGoObjects)
        privateProps.appendModel(loadDiagnosticObjects)
        privateProps.appendModel(loadManagementObjects)
        privateProps.appendModel(vdeObjects)
        privateProps.appendModel(notFilteredObjects)
        privateProps.appendModel(splitCommandObjects)
        paginator.refreshSize()
    }
}
