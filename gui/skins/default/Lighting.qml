import QtQuick 1.1
import Components.Lighting 1.0


SystemPage {
    source: "images/lighting.jpg"
    text: qsTr("lighting")
    rootColumn: Component { LightingItems {} }
    names: LightingNames {}
}

