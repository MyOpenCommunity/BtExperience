import QtQuick 1.1
import Components.Settings 1.0
import BtExperience 1.0
import "js/Stack.js" as Stack


/**
  \brief The Settings system page.
  */
SystemPage {
    source : homeProperties.homeBgImage
    text: qsTr("Settings")
    rootColumn: Component { SettingsItems {} }
    names: SettingsNames {}
    showSystemsButton: false

    /**
      Called when system button on navigation bar is clicked.
      Navigates back to settings page.
      */
    function systemsButtonClicked() {
        Stack.backToOptions()
    }

    /**
      Hook called when MenuContainer is closed.
      Navigates back to HomePage.
      */
    function systemPageClosed() {
        Stack.backToHome()
    }
}
