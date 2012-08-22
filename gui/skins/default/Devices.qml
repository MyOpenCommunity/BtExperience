import QtQuick 1.1
import Components.Multimedia 1.0


SystemPage {
    source: "images/multimedia.jpg"
    text: qsTr("Devices")
    rootColumn: Component { DevicesSystem {} }
    names: MultimediaNames {}
}
