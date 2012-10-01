import QtQuick 1.1
import Components.ThermalRegulation 1.0


SystemPage {
    source: "images/termoregolazione_riscaldamento.jpg"
    text: qsTr("temperature control")
    rootColumn: Component { ThermalRegulationItems {} }
    names: ThermalNames {}
}

