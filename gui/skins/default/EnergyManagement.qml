import QtQuick 1.1
import Components.EnergyManagement 1.0
import "js/Stack.js" as Stack
import "js/navigation.js" as Navigation

SystemPage {
    source: "images/background/energy.jpg"
    text: qsTr("Energy management")
    rootColumn: Component { EnergyManagementSystem {} }
    names: EnergyManagementNames {}
    showSettingsButton: true

    function settingsButtonClicked() {
        Stack.goToPage("Settings.qml", {"navigationTarget": Navigation.ENERGY_SETTINGS})
    }
}
