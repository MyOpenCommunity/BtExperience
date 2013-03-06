function getTarget(systemId) {
    switch (systemId) {
    case Container.IdScenarios:
        return "Scenarios.qml"
    case Container.IdLights:
        return "Lighting.qml"
    case Container.IdAutomation:
        return "Automation.qml"
    case Container.IdAirConditioning:
    case Container.IdThermalRegulation:
        return "ThermalRegulation.qml"
    case Container.IdLoadControl:
    case Container.IdSupervision:
    case Container.IdEnergyData:
        return "EnergyManagement.qml"
    case Container.IdVideoDoorEntry:
        return "VideoDoorEntry.qml"
    case Container.IdSoundDiffusionMulti:
    case Container.IdSoundDiffusionMono:
        return "SoundDiffusion.qml"
    case Container.IdAntintrusion:
        return "Antintrusion.qml"
    case Container.IdMessages:
        return "Messages.qml"
    default:
        return ""
    }
}

// Squash together similar systems. Since they may have different
// images and descriptions, we need to give a priority in case there
// are multiple items.
//
// These are the items in order of priority as implemented right now:
//  * Thermal regulation - Air conditioning
//  * Energy data - Load control - Supervision
function systemsModelContainers(systemsModel) {
    var containers = {}
    var objKeys = function (obj) {
        var keys = [];

        for(var key in obj)
            if (obj.hasOwnProperty(key))
                keys.push(key);

        return keys;
    }

    for (var i = 0; i < systemsModel.count; ++i) {
        var obj = systemsModel.getObject(i)

        switch (obj.containerId) {
        case Container.IdThermalRegulation:
        {
            delete containers[Container.IdAirConditioning]
            containers[Container.IdThermalRegulation] = undefined
            break
        }

        case Container.IdAirConditioning:
        {
            if (!(Container.IdThermalRegulation in containers))
                containers[Container.IdAirConditioning] = undefined
            break
        }

        case Container.IdEnergyData:
        {
            delete containers[Container.IdSupervision]
            delete containers[Container.IdLoadControl]
            containers[Container.IdEnergyData] = undefined
            break
        }

        case Container.IdLoadControl:
        {
            if (!(Container.IdEnergyData in containers)) {
                delete containers[Container.IdSupervision]
                containers[Container.IdLoadControl] = undefined
            }

            break
        }

        case Container.IdSupervision:
        {
            if (!(Container.IdEnergyData in containers || Container.IdLoadControl in containers)) {
                containers[Container.IdSupervision] = undefined
            }
            break
        }

        default:
            containers[obj.containerId] = undefined
        }
    }

    return objKeys(containers)
}
