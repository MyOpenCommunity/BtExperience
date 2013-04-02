import QtQuick 1.1
import Components.Lighting 1.0


/**
  \ingroup Lighting

  \brief The system page for Lighting system.
  */
SystemPage {
    source: "images/background/lighting.jpg"
    text: qsTr("lighting")
    rootColumn: Component { LightingItems {} }
    names: LightingNames {}
}

