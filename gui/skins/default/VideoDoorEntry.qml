import QtQuick 1.1
import Components.VideoDoorEntry 1.0
import "js/Stack.js" as Stack
import "js/navigation.js" as Navigation

SystemPage {
    source: "images/background/videocitofonia.jpg"
    text: qsTr("video door entry")
    rootColumn: Component { VideoDoorEntryItems {} }
    showSettingsButton: true

    function settingsButtonClicked() {
        Stack.goToPage("Settings.qml", {"navigationTarget": Navigation.VDE_SETTINGS})
    }
}

