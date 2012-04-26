import QtQuick 1.1
import Components.VideoDoorEntry 1.0


SystemPage {
    source: "images/videocitofonia.jpg"
    text: qsTr("video door entry")
    rootColumn: videoDoorEntryItems
    names: ThermalNames {}

    Component {
        id: videoDoorEntryItems
        VideoDoorEntryItems {}
    }
}

