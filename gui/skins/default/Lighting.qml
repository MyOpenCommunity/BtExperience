import QtQuick 1.1
import Components.Lighting 1.0


SystemPage {
    source: "images/illuminazione.jpg"
    text: qsTr("lighting")
    rootColumn: lightingItems

    Component {
        id: lightingItems
        LightingItems {}
    }
}

