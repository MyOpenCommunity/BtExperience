import QtQuick 1.1
import Components.Multimedia 1.0

import "js/Stack.js" as Stack


SystemPage {
    source: "images/multimedia.jpg"
    text: qsTr("Devices")
    rootColumn: Component { DevicesSystem {} }
    names: MultimediaNames {}

    function systemsButtonClicked() {
        Stack.backToMultimedia()
    }
}
