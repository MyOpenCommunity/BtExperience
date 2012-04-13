import QtQuick 1.1
import "js/Stack.js" as Stack

SystemPage {
    source: "images/videocitofonia.jpg"
    text: qsTr("video door entry")
    rootElement: "Components/VideoDoorEntry/VideoDoorEntryItems.qml"
    names: ThermalNames { }
}

