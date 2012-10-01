import QtQuick 1.1
import Components.EnergyManagement 1.0

SystemPage {
    source: "images/energy.jpg"
    text: qsTr("Energy management")
    rootColumn: Component { EnergyManagementSystem {} }
    names: EnergyManagementNames {}
}
