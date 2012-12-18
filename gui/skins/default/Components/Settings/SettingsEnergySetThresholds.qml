import QtQuick 1.1
import Components 1.0
import Components.Text 1.0

MenuColumn {
    id: column

    onChildDestroyed: {
        controlPanel.status = 0
    }

    Column {
        ControlSwitch {
            text: qsTr("threshold 1 %1").arg(status === 0 ? qsTr("enabled") : qsTr("disabled"))
            status: dataModel.thresholdEnabled[0] === true ? 0 : 1
            onClicked: dataModel.thresholdEnabled = [!dataModel.thresholdEnabled[0], dataModel.thresholdEnabled[1]]
        }

        ControlSwitch {
            text: qsTr("threshold 2 %1").arg(status === 0 ? qsTr("enabled") : qsTr("disabled"))
            status: dataModel.thresholdEnabled[1] === true ? 0 : 1
            onClicked: dataModel.thresholdEnabled = [dataModel.thresholdEnabled[0], !dataModel.thresholdEnabled[1]]
        }

        ControlSettings {
            id: controlPanel
            upperLabel: qsTr("threshold 1")
            upperText: dataModel.thresholds[0].toFixed(3) + " " + dataModel.currentUnit
            bottomLabel: qsTr("threshold 2")
            bottomText: dataModel.thresholds[1].toFixed(3) + " " + dataModel.currentUnit
            onEditClicked: {
                column.loadColumn(panelComponent, dataModel.name, dataModel)
                status = status === 0 ? 1 : 0
            }

            Component {
                id: panelComponent
                SettingsEnergySetThresholdsPanel {

                }
            }
        }
    }
}
