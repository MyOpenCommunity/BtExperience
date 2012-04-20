import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: column
    height: buttonOnOff.height + volumeSlider.height + amplifierSettings.height
    width: 212

    onChildDestroyed: amplifierSettings.state = ""

    ButtonOnOff {
        id: buttonOnOff
        status: column.dataModel.active
        height: 50
        onClicked: column.dataModel.active = newStatus
    }

    ControlSlider {
        id: volumeSlider
        anchors.top: buttonOnOff.bottom
        description: qsTr("volume")
        percentage: (column.dataModel.volume) * 100 / 31
        // TODO: add a volumeUp/Down in the model
//        onMinusClicked: column.dataModel.volume = column.dataModel.volume - 1
//        onPlusClicked: column.dataModel.volume = column.dataModel.volume + 1
    }

    MenuItem {
        id: amplifierSettings
        anchors.top: volumeSlider.bottom
        name: qsTr("settings")
        hasChild: true
        onClicked: {
            state = "selected"
            column.loadElement("Components/SoundDiffusion/AmplifierSettings.qml", qsTr("settings"), column.dataModel)
        }
    }
}
