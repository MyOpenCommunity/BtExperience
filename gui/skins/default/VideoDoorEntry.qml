import QtQuick 1.1
import Components.VideoDoorEntry 1.0


SystemPage {
    source: "images/background/videocitofonia.jpg"
    text: qsTr("video door entry")
    rootColumn: Component { VideoDoorEntryItems {} }
}

