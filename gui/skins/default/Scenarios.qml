import QtQuick 1.1
import Components.Scenarios 1.0
import BtObjects 1.0
import "js/Stack.js" as Stack
import "js/navigation.js" as Navigation


/**
  \ingroup Scenarios

  \brief The Scenarios system page.
  */
SystemPage {
    source: "images/background/scenario.jpg"
    text: systemNames.get(Container.IdScenarios)
    rootColumn: Component { ScenarioSystem {} }
    showSettingsButton: true

    /**
      Called when settings button on navigation bar is clicked.
      Navigates to scenarios settings.
      */
    function settingsButtonClicked() {
        Stack.goToPage("Settings.qml", {"navigationTarget": Navigation.SCENARIO_SETTINGS})
    }
}
