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
        if (mode === SplitAdvancedProgram.ModeFan)
            options.setComponent(fancoil)
        else if (mode === SplitAdvancedProgram.ModeOff)
            options.setComponent(off)
        else if (mode === SplitAdvancedProgram.ModeDehumidification)
            options.setComponent(dehum)
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
            isSelected: privateProps.currentIndex === 1
            onClicked: {
                if (privateProps.currentIndex !== 1)
                    privateProps.currentIndex = 1
                column.loadColumn(programListSplit, name, dataModel)
            }
        }

        MenuItem {
            id: modalityItem
            name: qsTr("modality")
            description: {
                if (dataModel.mode === -1)
                    return ""
                return pageObject.names.get('MODE', dataModel.mode)
            }
            hasChild: true
            isSelected: privateProps.currentIndex === 2
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
        id: dehum

        Column {
            ControlLeftRightWithTitle {
                id: swing
                visible: dataModel.swings.values.length > 0
                title: qsTr("swing")
                text: {
                    if (dataModel.swing === -1)
                        return ""
                    return pageObject.names.get('SWING', dataModel.swing)
                }
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

    Component {
        id: temperature

        Column {
            id: tempColumn
            property int setpoint

            Component.onCompleted: {
                tempColumn.setpoint = dataModel.setPoint // we want an assignment, not a binding
            }

            Connections {
                target: dataModel
                onSetPointChanged: {
                    tempColumn.setpoint = dataModel.setPoint
                }
            }

            ControlMinusPlus {
                id: temp
                title: qsTr("temperature")
                text: (tempColumn.setpoint / 10).toFixed(1) + "°C"
                onMinusClicked: {
                    if (tempColumn.setpoint - dataModel.setPointStep < dataModel.setPointMin)
                        return
                    dataModel.resetProgram()
                    tempColumn.setpoint -= dataModel.setPointStep
                }
                onPlusClicked: {
                    if (tempColumn.setpoint + dataModel.setPointStep > dataModel.setPointMax)
                        return
                    dataModel.resetProgram()
                    tempColumn.setpoint += dataModel.setPointStep
                }
            }
            ControlLeftRightWithTitle {
                id: fancoilMode
                visible: dataModel.speeds.values.length > 0
                title: qsTr("fancoil")
                text:  {
                    if (dataModel.speed === -1)
                        return ""
                    return pageObject.names.get('SPEED', dataModel.speed)
                }
                onLeftClicked: dataModel.prevSpeed()
                onRightClicked: dataModel.nextSpeed()
            }
            ControlLeftRightWithTitle {
                id: swing
                visible: dataModel.swings.values.length > 0
                title: qsTr("swing")
                text: {
                    if (dataModel.swing === -1)
                        return ""
                    return pageObject.names.get('SWING', dataModel.swing)
                }
                onLeftClicked: dataModel.prevSwing()
                onRightClicked: dataModel.nextSwing()
            }
            ButtonOkCancel {
                onCancelClicked: column.closeColumn()
                onOkClicked: {
                    dataModel.setPoint = tempColumn.setpoint
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
                visible: dataModel.speeds.values.length > 0
                title: qsTr("fancoil")
                text:  {
                    if (dataModel.speed === -1)
                        return ""
                    return pageObject.names.get('SPEED', dataModel.speed)
                }
                onLeftClicked: dataModel.prevSpeed()
                onRightClicked: dataModel.nextSpeed()
            }
            ControlLeftRightWithTitle {
                id: swing
                visible: dataModel.swings.values.length > 0
                title: qsTr("swing")
                text: {
                    if (dataModel.swing === -1)
                        return ""
                    return pageObject.names.get('SWING', dataModel.swing)
                }
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
