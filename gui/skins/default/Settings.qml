import QtQuick 1.1
import Components.Settings 1.0

import "js/Stack.js" as Stack


SystemPage {
    source: "images/illuminazione.jpg"
    text: qsTr("Settings")
    rootColumn: Component { SettingsItems {} }
    names: SettingsNames {}
    onClosed: Stack.popPage()

    function systemsButtonClicked() {
        Stack.backToOptions()
    }
}
