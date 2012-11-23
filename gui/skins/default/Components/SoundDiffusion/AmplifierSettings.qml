import QtQuick 1.1
import Components 1.0

MenuColumn {
    id: column

    Component {
        id: amplifierEqualizer
        AmplifierEqualizer {}
    }

    Component {
        id: loudness
        Loudness {}
    }

    onChildDestroyed: privateProps.currentIndex = -1

    QtObject {
        id: privateProps
        property int currentIndex: -1
    }

    PaginatorColumn {
        id: paginator
        anchors.horizontalCenter: parent.horizontalCenter
        maxHeight: 400

        Column {
            ControlSlider {
                id: treble
                description: qsTr("treble")
                // TODO: wrong value (#13411)
                percentage: column.dataModel.treble
            }

            ControlSlider {
                id: bass
                description: qsTr("bass")
                // TODO: this is the wrong value, see ticket #13411
                percentage: column.dataModel.bass
            }
        }

        Column {
            ControlBalance {
                id: balance
                value: column.dataModel.balance
            }

            MenuItem {
                id: equalizer
                name: qsTr("equalizer")
                description: column.dataModel.presetDescription
                hasChild: true
                isSelected: privateProps.currentIndex === 0
                onClicked: {
                    column.loadColumn(amplifierEqualizer, qsTr("equalizer"), column.dataModel)
                    if (privateProps.currentIndex !== 0)
                        privateProps.currentIndex = 0
                }
            }

            MenuItem {
                id: loudnessMenu
                name: qsTr("loud")
                description: column.dataModel.loud ? qsTr("on") : qsTr("off")
                hasChild: true
                isSelected: privateProps.currentIndex === 1
                onClicked: {
                    column.loadColumn(loudness, qsTr("loud"), column.dataModel)
                    if (privateProps.currentIndex !== 1)
                        privateProps.currentIndex = 1
                }
            }
        }

        onCurrentPageChanged: column.closeChild()
    }
}
