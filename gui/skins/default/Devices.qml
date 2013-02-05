import QtQuick 1.1
import Components.Multimedia 1.0

import "js/Stack.js" as Stack


SystemPage {
    id: page
    source: "images/background/devices.jpg"
    text: qsTr("Devices")
    rootColumn: Component { DevicesSystem { restoreBrowserState: page.restoreBrowserState } }

    property bool restoreBrowserState

    function multimediaButtonClicked() {
        Stack.backToMultimedia()
    }

    function systemPageClosed() {
        Stack.backToMultimedia()
    }

    showMultimediaButton: true
    showSystemsButton: false
}
