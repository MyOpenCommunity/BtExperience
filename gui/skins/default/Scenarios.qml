import QtQuick 1.1
import Components.Scenarios 1.0
import "js/Stack.js" as Stack
import "js/navigation.js" as Navigation

SystemPage {
    source: "images/background/scenario.jpg"
    text: qsTr("Scenarios")
    rootColumn: Component { ScenarioSystem {} }

    function settingsButtonClicked() {
        Stack.goToPage("Settings.qml", {"navigationTarget": Navigation.SCENARIO_SETTINGS})
    }

    showSettingsButton: true
}
