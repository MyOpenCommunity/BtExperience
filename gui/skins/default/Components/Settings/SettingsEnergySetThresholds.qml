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
            text: qsTr("threshold 1 enabled")
        }

        ControlSwitch {
            text: qsTr("threshold 2 enabled")
        }


        ControlSettings {
            id: controlPanel
            upperLabel: qsTr("threshold 1")
            upperText: dataModel.thresholds[0] + " " + dataModel.currentUnit
            bottomLabel: qsTr("threshold 2")
            bottomText: dataModel.thresholds[1] + " " + dataModel.currentUnit
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

        ControlSwitch {
            text: qsTr("alerts enabled")
        }
    }
}


