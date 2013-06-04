import QtQuick 1.1
import Components.EnergyManagement 1.0
import BtObjects 1.0
import "js/Stack.js" as Stack
import "js/navigation.js" as Navigation


/**
  \ingroup EnergyDataSystem

  \brief The system page for the EnergyManagement system.
  */
SystemPage {
    source: "images/background/energy.jpg"
    text: systemNames.get(Container.IdEnergyData)
    rootColumn: Component { EnergyManagementSystem {} }
    names: EnergyManagementNames {}
    showSettingsButton: true

    /**
      Called when system button on navigation bar is clicked.
      Navigates to energy settings.
      */
    function settingsButtonClicked() {
        Stack.goToPage("Settings.qml", {"navigationTarget": Navigation.ENERGY_SETTINGS})
    }
}
