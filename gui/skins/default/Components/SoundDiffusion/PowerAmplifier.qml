import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuElement {
    id: element
    height: buttonOnOff.height + volumeSlider.height + amplifierSettings.height
    width: 212

    onChildDestroyed: amplifierSettings.state = ""

    ButtonOnOff {
        id: buttonOnOff
        status: element.dataModel.active
        height: 50
        onClicked: element.dataModel.active = newStatus
    }

    ControlSlider {
        id: volumeSlider
        anchors.top: buttonOnOff.bottom
        description: qsTr("volume")
        percentage: (element.dataModel.volume) * 100 / 31
        // TODO: add a volumeUp/Down in the model
//        onMinusClicked: element.dataModel.volume = element.dataModel.volume - 1
//        onPlusClicked: element.dataModel.volume = element.dataModel.volume + 1
    }

    MenuItem {
        id: amplifierSettings
        anchors.top: volumeSlider.bottom
        name: qsTr("settings")
        hasChild: true
        onClicked: {
            state = "selected"
            element.loadElement("Components/SoundDiffusion/AmplifierSettings.qml", qsTr("settings"), element.dataModel)
        }
    }
}
