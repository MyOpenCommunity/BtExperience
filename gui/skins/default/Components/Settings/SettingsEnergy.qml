import QtQuick 1.1
import Components 1.0


MenuColumn {
    id: column

    QtObject {
        id: privateProps
        property int currentIndex: -1
    }

    onChildDestroyed: {
        privateProps.currentIndex = -1
    }

    Column {
        MenuItem {
            name: qsTr("tariffs")
            hasChild: true
            isSelected: privateProps.currentIndex === 1
            onTouched: {
                if (privateProps.currentIndex !== 1)
                    privateProps.currentIndex = 1

                column.loadColumn(tariffsComponent, name)
            }

            Component {
                id: tariffsComponent
                SettingsEnergyTariffs {
                }
            }
        }

        MenuItem {
            name: qsTr("consumption goals")
            hasChild: true
            isSelected: privateProps.currentIndex === 2
            onTouched: {
                if (privateProps.currentIndex !== 2)
                    privateProps.currentIndex = 2

                column.loadColumn(goalsComponent, name)
            }

            Component {
                id: goalsComponent
                SettingsEnergyGoals {
                }
            }
        }

        MenuItem {
            name: qsTr("thresholds")
            hasChild: true
            isSelected: privateProps.currentIndex === 3
            onTouched: {
                if (privateProps.currentIndex !== 3)
                    privateProps.currentIndex = 3
                column.loadColumn(thresholdsComponent, name)
            }

            Component {
                id: thresholdsComponent
                SettingsEnergyThresholds {
                }
            }
        }
    }

}

