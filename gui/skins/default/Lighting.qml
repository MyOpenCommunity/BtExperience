import QtQuick 1.1
import Components.Lighting 1.0
import BtObjects 1.0

/**
  \ingroup Lighting

  \brief The system page for Lighting system.
  */
SystemPage {
    source: "images/background/lighting.jpg"
    text: systemNames.get(Container.IdLights)
    rootColumn: Component { LightingItems {} }
    names: LightingNames {}
}

