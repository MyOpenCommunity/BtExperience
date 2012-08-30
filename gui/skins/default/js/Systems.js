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
    case Container.IdSoundDiffusion:
        return "SoundDiffusion.qml"
    case Container.IdAntintrusion:
        return "Antintrusion.qml"
    case Container.IdMessages:
        return "Messages.qml"
    default:
        return ""
    }
}
