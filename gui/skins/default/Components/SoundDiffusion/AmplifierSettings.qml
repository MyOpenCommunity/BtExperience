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
            ControlBalance {
                id: treble
                description: qsTr("treble")
                // TODO: wrong value (#13411)
                balance: column.dataModel.treble
                rightText: "+"
                leftText: "-"
                onRightClicked: column.dataModel.trebleUp()
                onLeftClicked: column.dataModel.trebleDown()
            }

            ControlBalance {
                id: bass
                description: qsTr("bass")
                // TODO: this is the wrong value, see ticket #13411
                balance: column.dataModel.bass
                rightText: "+"
                leftText: "-"
                onRightClicked: column.dataModel.bassUp()
                onLeftClicked: column.dataModel.bassDown()
            }
        }

        Column {
            ControlBalance {
                id: balance
                balance: column.dataModel.balance
                onRightClicked: column.dataModel.balanceRight()
                onLeftClicked: column.dataModel.balanceLeft()
            }

            MenuItem {
                id: equalizer
                name: qsTr("equalizer")
                description: column.dataModel.presetDescription
                hasChild: true
                state: privateProps.currentElement === 0 ? "selected" : ""
                onClicked: {
                    column.loadColumn(
                                amplifierEqualizer,
                                qsTr("equalizer"),
                                column.dataModel)
                    if (privateProps.currentElement !== 0)
                        privateProps.currentElement = 0
                }
            }

            MenuItem {
                id: loudnessMenu
                name: qsTr("loud")
                description: column.dataModel.loud ? qsTr("on") : qsTr("off")
                hasChild: true
                state: privateProps.currentElement === 1 ? "selected" : ""
                onClicked: {
                    column.loadColumn(
                                loudness,
                                qsTr("loud"),
                                column.dataModel)
                    if (privateProps.currentElement !== 1)
                        privateProps.currentElement = 1
                }
            }
        }

        onCurrentPageChanged: column.closeChild()
    }
}
