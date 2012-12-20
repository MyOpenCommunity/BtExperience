import QtQuick 1.1
import Components.Scenarios 1.0
import "js/Stack.js" as Stack

SystemPage {
    source: "images/background/scenario.jpg"
    text: qsTr("Scenarios")
    rootColumn: Component { ScenarioSystem {} }

    function settingsButtonClicked() {
        Stack.backToOptions()
    }

    showSettingsButton: true
}
