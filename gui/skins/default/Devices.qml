import QtQuick 1.1
import Components.Multimedia 1.0

import "js/Stack.js" as Stack


SystemPage {
    source: "images/background/devices.jpg"
    text: qsTr("Devices")
    rootColumn: Component { DevicesSystem {} }
    names: MultimediaNames {}

    function multimediaButtonClicked() {
        Stack.backToMultimedia()
    }

    function systemPageClosed() {
        Stack.backToMultimedia()
    }

    showMultimediaButton: true
    showSystemsButton: false
}
