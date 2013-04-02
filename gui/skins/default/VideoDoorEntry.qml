import QtQuick 1.1
import Components.VideoDoorEntry 1.0
import "js/Stack.js" as Stack
import "js/navigation.js" as Navigation


/**
  \ingroup VideoDoorEntry

  \brief The VideoDoorEntry system page.
  */
SystemPage {
    source: "images/background/video_door_entry.jpg"
    text: qsTr("video door entry")
    rootColumn: Component { VideoDoorEntryItems {} }
    showSettingsButton: true

    /**
      Called when settings button on navigation bar is clicked.
      Navigates to VideoDoorEntry settings.
      */
    function settingsButtonClicked() {
        Stack.goToPage("Settings.qml", {"navigationTarget": Navigation.VDE_SETTINGS})
    }
}

