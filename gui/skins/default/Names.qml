import QtQuick 1.1
import "js/array.js" as Script


/**
  \ingroup Core

  \brief Component containing all translations.
  */
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

    // internal function to load values into the container
    function _init(container) {
        antintrusionNames._init(container)
        energyManagementNames._init(container)
        lightingNames._init(container)
        settingsNames._init(container)
        thermalNames._init(container)
    }

    /**
      Retrieves the requested value from the local array.
      @param type:string context The translation context to distinguish between similar id.
      @param type:int id The id referring to the string to be translated.
      */
    function get(context, id) {
        if (Script.container.length === 0)
            _init(Script.container)

        return Script.container[context][id]
    }
}
