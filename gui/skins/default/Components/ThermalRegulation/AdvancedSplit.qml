import QtQuick 1.1
import Components 1.0
import BtObjects 1.0
import "../../js/logging.js" as Log

MenuColumn {
    id: element
    width: 212
    height: paginator.height

    QtObject {
        id: privateProps
        property int currentIndex: -1
    }

    onChildDestroyed: privateProps.currentIndex = -1

    Component.onCompleted: {
        modalityChanged(dataModel.mode)
    }

    onChildLoaded: {
        if (child.modalityChanged)
            child.modalityChanged.connect(modalityChanged)
    }

    function modalityChanged(mode) {
        if (mode === SplitAdvancedScenario.ModeFan)
            options.setComponent(fancoil)
        else if (mode === SplitAdvancedScenario.ModeOff
                 || mode === SplitAdvancedScenario.ModeDehumidification)
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
            description: qsTr("morning")
            hasChild: true
            state: privateProps.currentIndex === 1 ? "selected" : ""
            onClicked: {
                if (privateProps.currentIndex !== 1)
                    privateProps.currentIndex = 1
                // TODO: this is just to load a page with programs...
                element.loadElement("Components/ThermalRegulation/BasicSplit.qml", name)
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
                element.loadElement("Components/ThermalRegulation/AdvancedSplitModalities.qml", name)
            }
        }

        AnimatedLoader {
            id: options
        }
    }

    Component {
        id: temperature
        Column {
            ControlMinusPlus {
                id: temp
                title: qsTr("temperature")
                property int currentTemp: dataModel.setPoint
                text: currentTemp + " " + qsTr("°C")
                onMinusClicked: --currentTemp
                onPlusClicked: ++currentTemp
            }
            ControlUpDown {
                id: fancoilMode
                title: qsTr("fancoil")
                text: pageObject.names.get('SPEED', currentIndex)
                property int currentIndex: dataModel.speed
                onDownClicked: if (currentIndex > 0) --currentIndex
                onUpClicked: if(currentIndex < 4) ++currentIndex
            }
            ControlUpDown {
                id: swing
                title: qsTr("swing")
                text: pageObject.names.get('SWING', currentIndex)
                property int currentIndex: dataModel.swing
                onDownClicked: if (currentIndex > 0) --currentIndex
                onUpClicked: if (currentIndex < 1) ++currentIndex
            }
            ButtonOkCancel {
                onCancelClicked: element.closeElement()
                onOkClicked: {
                    dataModel.speed = fancoilMode.currentIndex
                    dataModel.swing = swing.currentIndex
                    dataModel.setPoint = temp.currentTemp
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
                onDownClicked: if (currentIndex > 0) --currentIndex
                onUpClicked: if(currentIndex < 4) ++currentIndex
            }
            ControlUpDown {
                id: swing
                title: qsTr("swing")
                text: pageObject.names.get('SWING', currentIndex)
                property int currentIndex: dataModel.swing
                onDownClicked: if (currentIndex > 0) --currentIndex
                onUpClicked: if (currentIndex < 1) ++currentIndex
            }
            ButtonOkCancel {
                onCancelClicked: element.closeElement()
                onOkClicked: {
                    dataModel.speed = fancoilMode.currentIndex
                    dataModel.swing = swing.currentIndex
                }
            }
        }
    }

    Component {
        id: off
        ButtonOkCancel {
            onCancelClicked: element.closeElement()
        }
    }
}
