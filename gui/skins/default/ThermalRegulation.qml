import QtQuick 1.1
import "Stack.js" as Stack

SystemPage {
    source: "images/termoregolazione.jpg"
    text: qsTr("temperature control")
    rootElement: "ThermalRegulationItems.qml"
    names: ThermalNames { }
}

