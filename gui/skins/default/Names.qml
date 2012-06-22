import QtQuick 1.1
import "js/array.js" as Script


Item {
    AntintrusionNames {
        id: antintrusionNames
    }

    EnergyManagementNames {
        id: energyManagementNames
    }

    LightingNames {
        id: lightingNames
    }

    SettingsNames {
        id: settingsNames
    }

    ThermalNames {
        id: thermalNames
    }

    VideoDoorEntryNames {
        id: videoDoorEntryNames
    }

    // internal function to load values into the container
    function _init(container) {
        antintrusionNames._init(container)
        energyManagementNames._init(container)
        lightingNames._init(container)
        settingsNames._init(container)
        thermalNames._init(container)
        videoDoorEntryNames._init(container)
    }

    // retrieves the requested value from the local array
    function get(context, id) {
        if (Script.container.length === 0)
            _init(Script.container)

        return Script.container[context][id]
    }
}
