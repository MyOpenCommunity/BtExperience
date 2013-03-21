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
        maxHeight: 300

        ControlBalance {
            id: treble
            description: qsTr("treble")
            value: column.dataModel.treble
            onLeftClicked: column.dataModel.trebleDown()
            onRightClicked: column.dataModel.trebleUp()
        }

        ControlBalance {
            id: bass
            description: qsTr("bass")
            value: column.dataModel.bass
            onLeftClicked: column.dataModel.bassDown()
            onRightClicked: column.dataModel.bassUp()
        }

        ControlBalance {
            id: balance
            value: column.dataModel.balance
            onLeftClicked: column.dataModel.balanceLeft()
            onRightClicked: column.dataModel.balanceRight()
        }

        MenuItem {
            id: equalizer
            name: qsTr("equalizer")
            description: column.dataModel.presetDescription
            hasChild: true
            isSelected: privateProps.currentIndex === 0
            onTouched: {
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
            onTouched: {
                column.loadColumn(loudness, qsTr("loud"), column.dataModel)
                if (privateProps.currentIndex !== 1)
                    privateProps.currentIndex = 1
            }
        }

        onCurrentPageChanged: column.closeChild()
    }
}
