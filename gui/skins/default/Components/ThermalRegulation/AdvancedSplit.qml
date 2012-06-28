import QtQuick 1.1
import Components 1.0
import BtObjects 1.0
import "../../js/logging.js" as Log

MenuColumn {
    id: column

    Component {
        id: programListSplit
        ProgramListSplit {}
    }

    Component {
        id: advancedSplitModalities
        AdvancedSplitModalities {}
    }

    QtObject {
        id: privateProps
        property int currentIndex: -1
    }

    onChildDestroyed: privateProps.currentIndex = -1

    Component.onCompleted: {
        modeChanged(dataModel.mode)
    }

    onChildLoaded: {
        if (child.modeChanged)
            child.modeChanged.connect(modeChanged)
    }

    function modeChanged(mode) {
        if (dataModel.mode !== mode)
            dataModel.resetProgram()
        dataModel.mode = mode
        if (mode === SplitProgram.ModeFan)
            options.setComponent(fancoil)
        else if (mode === SplitProgram.ModeOff ||
                 mode === SplitProgram.ModeDehumidification)
            options.setComponent(off)
        else
            options.setComponent(temperature)
    }

    PaginatorColumn {
        id: paginator
        anchors.horizontalCenter: parent.horizontalCenter
        maxHeight: 500

        MenuItem {
            id: programItem
            name: qsTr("program")
            description: dataModel.program
            hasChild: true
            state: privateProps.currentIndex === 1 ? "selected" : ""
            onClicked: {
                if (privateProps.currentIndex !== 1)
                    privateProps.currentIndex = 1
                column.loadColumn(programListSplit, name, dataModel)
            }
        }

        MenuItem {
            id: modalityItem
            name: qsTr("modality")
            description: pageObject.names.get('MODE', dataModel.mode)
            hasChild: true
            state: privateProps.currentIndex === 2 ? "selected" : ""
            onClicked: {
                if (privateProps.currentIndex !== 2)
                    privateProps.currentIndex = 2
                column.loadColumn(advancedSplitModalities, name, dataModel)
            }
        }

        AnimatedLoader {
            id: options
            onItemChanged: {
                // TODO when loaded item changes menu height is not updated
                // this trick is to force height update
                paginator.height = programItem.height + modalityItem.height
                if (item)
                    paginator.height += item.height
            }
        }
    }

    Component {
        id: off
        ButtonOkCancel {
            onCancelClicked: column.closeColumn()
            onOkClicked: {
                dataModel.apply()
                column.closeColumn()
            }
        }
    }

    Component {
        id: temperature
        // TODO how to manage temperatures formats?
        Column {
            ControlMinusPlus {
                id: temp
                title: qsTr("temperature")
                property int currentTemp: dataModel.setPoint / 10
                text: currentTemp + " " + qsTr("°C")
                onMinusClicked: {
                    dataModel.resetProgram()
                    --currentTemp
                }
                onPlusClicked: {
                    dataModel.resetProgram()
                    ++currentTemp
                }
            }
            ControlLeftRightWithTitle {
                id: fancoilMode
                title: qsTr("fancoil")
                text: pageObject.names.get('SPEED', dataModel.speed)
                onLeftClicked: dataModel.prevSpeed()
                onRightClicked: dataModel.nextSpeed()
            }
            ControlLeftRightWithTitle {
                id: swing
                title: qsTr("swing")
                text: pageObject.names.get('SWING', dataModel.swing)
                onLeftClicked: dataModel.prevSwing()
                onRightClicked: dataModel.nextSwing()
            }
            ButtonOkCancel {
                onCancelClicked: column.closeColumn()
                onOkClicked: {
                    dataModel.setPoint = temp.currentTemp * 10
                    dataModel.apply()
                    column.closeColumn()
                }
            }
        }
    }

    Component {
        id: fancoil

        Column {
            ControlLeftRightWithTitle {
                id: fancoilMode
                title: qsTr("fancoil")
                text: pageObject.names.get('SPEED', dataModel.speed)
                onLeftClicked: dataModel.prevSpeed()
                onRightClicked: dataModel.nextSpeed()
            }
            ControlLeftRightWithTitle {
                id: swing
                title: qsTr("swing")
                text: pageObject.names.get('SWING', dataModel.swing)
                onLeftClicked: dataModel.prevSwing()
                onRightClicked: dataModel.nextSwing()
            }
            ButtonOkCancel {
                onCancelClicked: column.closeColumn()
                onOkClicked: {
                    dataModel.apply()
                    column.closeColumn()
                }
            }
        }
    }
}
