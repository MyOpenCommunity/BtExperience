import QtQuick 1.1
import Components.ThermalRegulation 1.0


SystemPage {
    source: "images/termoregolazione.jpg"
    text: qsTr("temperature control")
    rootColumn: thermalRegulationItems
    names: ThermalNames {}

    Component {
        id: thermalRegulationItems
        ThermalRegulationItems {}
    }
}

