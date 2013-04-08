import QtQuick 1.1
import Components.Multimedia 1.0
import "js/Stack.js" as Stack


/**
  \ingroup Multimedia

  \brief A system page to show all available devices.

  This page shows all available devices like USB/SD or media servers.
  The user may browser inside devices and see file content.
  Clicking on a specific file the correspondent player is started.
  */
SystemPage {
    id: page

    property bool restoreBrowserState

    source: "images/background/devices.jpg"
    text: qsTr("Devices")
    rootColumn: Component { DevicesSystem { restoreBrowserState: page.restoreBrowserState } }
    showMultimediaButton: true
    showSystemsButton: false

    /**
      Called when multimedia button on navigation bar is clicked.
      Navigates back to multimedia page.
      */
    function multimediaButtonClicked() {
        Stack.backToMultimedia()
    }

    /**
      Hook called when MenuContainer is closed.
      Navigates back to multimedia page.
      */
    function systemPageClosed() {
        Stack.backToMultimedia()
    }
}
