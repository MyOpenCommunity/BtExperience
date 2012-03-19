import QtQuick 1.1

MenuElement {
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
                percentage: 10
            }

            ControlSlider {
                id: bass
                description: qsTr("bass")
                percentage: 35
            }
        }

        Column {
            ControlBalance {
                id: balance
                percentage: 10
            }

            MenuItem {
                id: equalizer
                name: qsTr("equalizer")
                active: amplifierSettings.animationRunning === false
                description: "off"
                hasChild: true
                state: privateProps.currentElement === 0 ? "selected" : ""
                onClicked: {
                    amplifierSettings.loadElement("AmplifierEqualizer.qml", qsTr("equalizer"))
                    if (privateProps.currentElement !== 0)
                        privateProps.currentElement = 0
                }
            }

            MenuItem {
                id: loudness
                name: qsTr("loud")
                active: amplifierSettings.animationRunning === false
                description: "on"
                hasChild: true
                state: privateProps.currentElement === 1 ? "selected" : ""
                // TODO: a dirty trick to avoid creating another almost empty file.
                // This must be linked to the model anyway.
                onClicked: {
                    amplifierSettings.loadElement("Light.qml", qsTr("loud"))
                    if (privateProps.currentElement !== 1)
                        privateProps.currentElement = 1
                }
            }
        }
    }
}
