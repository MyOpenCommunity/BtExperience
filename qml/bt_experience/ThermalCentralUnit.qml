import QtQuick 1.1
import BtObjects 1.0


MenuElement {
    id: element
    width: 212
    height: seasonItem.height + modalityItem.height + itemLoader.height

    QtObject {
        id: privateProps
        property int current_element: -1
    }

    function alertOkClicked() {
        element.closeElement()
    }

    onChildLoaded: {
        if (child.modalitySelected)
            child.modalitySelected.connect(modalitySelected)
    }

    onChildDestroyed: {
        modalityItem.state = "";
    }

    function modalitySelected(modalityName, modalityId) {
        modalityItem.description = modalityName

        console.log('MODALITY ID: ' + modalityId)
        switch (modalityId) {
        case ThermalControlUnit99Zones.IdHoliday:
            itemLoader.changeComponent(holidayComponent)
            break
        case ThermalControlUnit99Zones.IdOff:
            itemLoader.changeComponent(offComponent)
            break
        case ThermalControlUnit99Zones.IdAntifreeze:
            itemLoader.changeComponent(antifreezeComponent)
            break
        case ThermalControlUnit99Zones.IdWeeklyPrograms:
            itemLoader.changeComponent(programsComponent)
            break
        case ThermalControlUnit99Zones.IdVacation:
            itemLoader.changeComponent(vacationComponent)
            break
        case ThermalControlUnit99Zones.IdScenarios:
            itemLoader.changeComponent(scenarioComponent)
            break

        }
    }


    function okClicked() {
        closeElement();
    }

    function cancelClicked() {
        page.showAlert(element, "Modifiche non salvate. Continuare?")
    }


    Item {
        id: mainItem
        width: 212
        height: 326
        anchors.fill: parent

        MenuItem {
            id: seasonItem
            anchors.top: parent.top
            name: qsTr("funzionamento")
            state: privateProps.current_element == 1 ? "selected" : ""

            onClicked: {
                element.loadElement("ThermalCentralUnitSeasons.qml", seasonItem.name, element.dataModel)
                if (privateProps.current_element != 1)
                    privateProps.current_element = 1
            }
        }

        MenuItem {
            id: modalityItem
            anchors.top: seasonItem.bottom
            name: qsTr("modalità")
            state: privateProps.current_element == 2 ? "selected" : ""

            onClicked: {
                element.loadElement("ThermalCentralUnitModalities.qml", modalityItem.name, element.dataModel)
                if ( privateProps.current_element != 2)
                    privateProps.current_element = 2
            }
        }

        Component {
            id: holidayComponent
            Column {
                ControlDateTime {
                    text: qsTr("attivo fino al")
                    date: "18/01/2012"
                    time: "13:00"
                }
                ControlUpDown {
                    title: qsTr("programma successivo")
                    text: "settimanale P1"
//                    onUpClicked: changeMode();
//                    onDownClicked: changeMode();
                }
                ButtonOkCancel {
                    onCancelClicked: element.cancelClicked();
                    onOkClicked: element.okClicked();
                }
            }
        }

        Component {
            id: offComponent
            Column {
                ButtonOkCancel {
                    onCancelClicked: element.cancelClicked();
                    onOkClicked: element.okClicked();
                }
            }
        }

        Component {
            id: antifreezeComponent
            Column {
                ButtonOkCancel {
                    onCancelClicked: element.cancelClicked();
                    onOkClicked: element.okClicked();
                }
            }
        }

        Component {
            id: programsComponent
            Column {
                ControlDateTime {
                    text: qsTr("attivo fino al")
                    date: "18/01/2012"
                    time: "13:00"
                }
                ControlUpDown {
                    title: qsTr("programma successivo")
                    text: "settimanale P1"
//                    onUpClicked: changeMode();
//                    onDownClicked: changeMode();
                }
                ButtonOkCancel {
                    onCancelClicked: element.cancelClicked();
                    onOkClicked: element.okClicked();
                }
            }
        }

        Component {
            id: vacationComponent
            Column {
                ControlDateTime {
                    text: qsTr("attivo fino al")
                    date: "18/01/2012"
                    time: "13:00"
                }
                ControlUpDown {
                    title: qsTr("programma successivo")
                    text: "settimanale P1"
//                    onUpClicked: changeMode();
//                    onDownClicked: changeMode();
                }
                ButtonOkCancel {
                    onCancelClicked: element.cancelClicked();
                    onOkClicked: element.okClicked();
                }
            }
        }

        Component {
            id: scenarioComponent
            Column {
                ControlUpDown {
                    title: qsTr("selezionato")
                    text: "scenario 1"
//                    onUpClicked: changeMode();
//                    onDownClicked: changeMode();
                }
                ButtonOkCancel {
                    onCancelClicked: element.cancelClicked();
                    onOkClicked: element.okClicked();
                }
            }
        }

        AnimatedLoader {
            id: itemLoader
            anchors.top: modalityItem.bottom
        }

        /*
        ControlMinusPlus {
            id: itemTemperature
            anchors.top: modalityItem.bottom
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
        */

    }
}
