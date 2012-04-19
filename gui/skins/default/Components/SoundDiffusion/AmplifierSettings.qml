import QtQuick 1.1
import Components 1.0

MenuColumn {
    id: amplifierSettings
    width: 212
    height: paginator.height

    onChildDestroyed: privateProps.currentElement = -1

    QtObject {
        id: privateProps
        property int currentElement: -1
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
                percentage: amplifierSettings.dataModel.treble
            }

            ControlSlider {
                id: bass
                description: qsTr("bass")
                // TODO: this is the wrong value, see ticket #13411
                percentage: amplifierSettings.dataModel.bass
            }
        }

        Column {
            ControlBalance {
                id: balance
                percentage: amplifierSettings.dataModel.balance
            }

            MenuItem {
                id: equalizer
                name: qsTr("equalizer")
                description: amplifierSettings.dataModel.presetDescription
                hasChild: true
                state: privateProps.currentElement === 0 ? "selected" : ""
                onClicked: {
                    amplifierSettings.loadElement("Components/SoundDiffusion/AmplifierEqualizer.qml", qsTr("equalizer"), amplifierSettings.dataModel)
                    if (privateProps.currentElement !== 0)
                        privateProps.currentElement = 0
                }
            }

            MenuItem {
                id: loudness
                name: qsTr("loud")
                description: amplifierSettings.dataModel.loud ? qsTr("on") : qsTr("off")
                hasChild: true
                state: privateProps.currentElement === 1 ? "selected" : ""
                // TODO: a dirty trick to avoid creating another almost empty file.
                // This must be linked to the model anyway.
                onClicked: {
                    amplifierSettings.loadElement("Components/SoundDiffusion/Loudness.qml", qsTr("loud"), amplifierSettings.dataModel)
                    if (privateProps.currentElement !== 1)
                        privateProps.currentElement = 1
                }
            }
        }

        onCurrentPageChanged: amplifierSettings.closeChild()
    }
}
