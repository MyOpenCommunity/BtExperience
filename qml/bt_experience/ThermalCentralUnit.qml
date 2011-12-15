import QtQuick 1.1
import BtObjects 1.0


MenuElement {
    id: element
    width: 212
    height: 323

    function alertOkClicked() {
        element.closeElement()
    }

    onChildLoaded: {
        child.programSelected.connect(programSelected)
    }

    onChildDestroyed: {
        programItem.state = "";
    }

    function programSelected(programName) {
        programItem.description = programName
        if (programName == "antigelo")
            element.state = "temperatureDisabled"
        else if (programName == "off")
            element.state = "controlsDisabled"
        else
            element.state = ""
    }


    Item {
        id: mainItem
        width: 212
        height: 326
        anchors.fill: parent

        MenuItem {
            id: programItem
            name: qsTr("programma")

            onClicked: {
                element.loadElement("ThermalCentralUnitModalities.qml", programItem.name, element.dataModel)
                if (programItem.state == "")
                    programItem.state =  "selected"
            }
        }

        ControlMinusPlus {
            id: itemTemperature
            anchors.top: programItem.bottom
            anchors.topMargin: 0
            title: qsTr("temperatura impostata")
            text: dataModel.temperature / 10 + "°"
            onMinusClicked: dataModel.temperature -= 5
            onPlusClicked: dataModel.temperature += 5
        }

        ControlUpDown {
            id: itemMode
            anchors.top: itemTemperature.bottom
            anchors.topMargin: 0
            title: qsTr("modo")
            text: dataModel.mode == ThermalControlUnit99Zones.SummerMode ? qsTr("estate") : qsTr("inverno")

            function changeMode() {
                dataModel.mode = (dataModel.mode == ThermalControlUnit99Zones.SummerMode) ?
                            ThermalControlUnit99Zones.WinterMode : ThermalControlUnit99Zones.SummerMode
            }
            onUpClicked: changeMode();
            onDownClicked: changeMode();
        }

        ButtonOkCancel {
            id: buttonokcancel
            anchors.top: itemMode.bottom
            onCancelClicked: {
                page.showAlert(element, "Modifiche non salvate. Continuare?")
            }

            onOkClicked: {
                element.closeElement()
            }
        }
    }
    states: [
        State {
            name: "temperatureDisabled"

            PropertyChanges {
                target: itemTemperature
                opacity: 0.400
            }

            PropertyChanges {
                target: minusMouseArea
                enabled: false
            }

            PropertyChanges {
                target: plusMouseArea
                enabled: false
            }

            PropertyChanges {
                target: element
            }
        },
        State {
            name: "controlsDisabled"
            PropertyChanges {
                target: itemTemperature
                opacity: 0.400
            }

            PropertyChanges {
                target: itemMode
                opacity: 0.400
            }

            PropertyChanges {
                target: plusMouseArea
                enabled: false
            }

            PropertyChanges {
                target: minusMouseArea
                enabled: false
            }

            PropertyChanges {
                target: mouse_area2
                enabled: false
            }

            PropertyChanges {
                target: mouse_area1
                enabled: false
            }
        }
    ]

}
