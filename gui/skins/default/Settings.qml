import QtQuick 1.1
import Components.Settings 1.0
import BtExperience 1.0

import "js/Stack.js" as Stack


SystemPage {
    source : homeProperties.homeBgImage
    text: qsTr("Settings")
    rootColumn: Component { SettingsItems {} }
    names: SettingsNames {}

    function systemsButtonClicked() {
        Stack.backToOptions()
    }

    function systemPageClosed() {
        Stack.backToHome()
    }

    showSystemsButton: false
}
