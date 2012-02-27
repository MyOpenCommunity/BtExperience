import QtQuick 1.1
import BtObjects 1.0

MenuElement {
    id: element
    height: buttonOnOff.height + volumeSlider.height + amplifierSettings.height
    width: 212

    ButtonOnOff {
        id: buttonOnOff
        status: false
        height: 50
    }

    ControlSlider {
        id: volumeSlider
        anchors.top: buttonOnOff.bottom
        description: qsTr("volume")
    }

    MenuItem {
        id: amplifierSettings
        active: element.animationRunning === false
        anchors.top: volumeSlider.bottom
        name: qsTr("impostazioni")
        hasChild: true
        onClicked: element.loadElement("AmplifierSettings.qml", "impostazioni", undefined)
    }
}
