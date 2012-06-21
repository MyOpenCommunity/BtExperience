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

    width: 212
    height: paginator.height

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
        else if (mode === SplitProgram.ModeOff
                 || mode === SplitProgram.ModeDehumidification)
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
                column.loadColumn(
                            programListSplit,
                            name,
                            dataModel)
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
                column.loadColumn(
                            advancedSplitModalities,
                            name,
                            dataModel)
            }
        }

        AnimatedLoader {
            id: options
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
            ControlUpDown {
                id: fancoilMode
                title: qsTr("fancoil")
                text: pageObject.names.get('SPEED', currentIndex)
                property int currentIndex: dataModel.speed
                onDownClicked: {
                    if (currentIndex > 0) {
                        dataModel.resetProgram()
                        --currentIndex
                    }
                }
                onUpClicked: {
                    if (currentIndex < 4) {
                        dataModel.resetProgram()
                        ++currentIndex
                    }
                }
            }
            ControlUpDown {
                id: swing
                title: qsTr("swing")
                text: pageObject.names.get('SWING', currentIndex)
                property int currentIndex: dataModel.swing
                onDownClicked: {
                    if (currentIndex > 0) {
                        dataModel.resetProgram()
                        --currentIndex
                    }
                }
                onUpClicked: {
                    if (currentIndex < 1) {
                        dataModel.resetProgram()
                        ++currentIndex
                    }
                }
            }
            ButtonOkCancel {
                onCancelClicked: column.closeColumn()
                onOkClicked: {
                    dataModel.speed = fancoilMode.currentIndex
                    dataModel.swing = swing.currentIndex
                    dataModel.setPoint = temp.currentTemp * 10
                    dataModel.ok()
                    column.closeColumn()
                }
            }
        }
    }

    Component {
        id: fancoil

        Column {
            ControlUpDown {
                id: fancoilMode
                title: qsTr("fancoil")
                text: pageObject.names.get('SPEED', currentIndex)
                property int currentIndex: dataModel.speed
                onDownClicked: {
                    if (currentIndex > 0) {
                        dataModel.resetProgram()
                        --currentIndex
                    }
                }
                onUpClicked: {
                    if (currentIndex < 4) {
                        dataModel.resetProgram()
                        ++currentIndex
                    }
                }
            }
            ControlUpDown {
                id: swing
                title: qsTr("swing")
                text: pageObject.names.get('SWING', currentIndex)
                property int currentIndex: dataModel.swing
                onDownClicked: {
                    if (currentIndex > 0) {
                        dataModel.resetProgram()
                        --currentIndex
                    }
                }
                onUpClicked: {
                    if (currentIndex < 1) {
                        dataModel.resetProgram()
                        ++currentIndex
                    }
                }
            }
            ButtonOkCancel {
                onCancelClicked: column.closeColumn()
                onOkClicked: {
                    dataModel.speed = fancoilMode.currentIndex
                    dataModel.swing = swing.currentIndex
                    dataModel.ok()
                    column.closeColumn()
                }
            }
        }
    }

    Component {
        id: off
        ButtonOkCancel {
            onCancelClicked: column.closeColumn()
            onOkClicked: {
                dataModel.ok()
                column.closeColumn()
            }
        }
    }
}
