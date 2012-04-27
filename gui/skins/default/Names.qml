import QtQuick 1.1
import BtObjects 1.0
import "js/array.js" as Script


QtObject {
    AntintrusionNames {
        id: antintrusionNames
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
        antintrusionNames._init(Script.container)
        settingsNames._init(Script.container)
        thermalNames._init(Script.container)
        videoDoorEntryNames._init(Script.container)
    }

    // retrieves the requested value from the local array
    function get(context, id) {
        if (Script.container.length === 0)
            _init(Script.container)

        return Script.container[context][id]
    }
}
