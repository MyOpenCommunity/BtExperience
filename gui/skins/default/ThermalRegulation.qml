import QtQuick 1.1
import "js/Stack.js" as Stack

SystemPage {
    source: "images/termoregolazione.jpg"
    text: qsTr("temperature control")
    rootElement: "Components/ThermalRegulation/ThermalRegulationItems.qml"
    names: ThermalNames { }
}

