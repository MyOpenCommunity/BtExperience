import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: column

    Component {
        id: amplifierSettings
        AmplifierSettings {}
    }

    onChildDestroyed: amplifierSettingsMenu.state = ""

    ControlOnOff {
        id: buttonOnOff
        status: column.dataModel.active
        onClicked: column.dataModel.active = newStatus
    }

    ControlSlider {
        id: volumeSlider
        anchors.top: buttonOnOff.bottom
        description: qsTr("volume")
        percentage: column.dataModel.volume
        onMinusClicked: column.dataModel.volumeDown()
        onPlusClicked: column.dataModel.volumeUp()
        onSliderClicked: column.dataModel.volume = desiredPercentage
    }

    MenuItem {
        id: amplifierSettingsMenu
        anchors.top: volumeSlider.bottom
        name: qsTr("settings")
        hasChild: true
        onClicked: {
            if (!isSelected)
                isSelected = true
            column.loadColumn(amplifierSettings, qsTr("settings"), column.dataModel)
        }
    }
}
