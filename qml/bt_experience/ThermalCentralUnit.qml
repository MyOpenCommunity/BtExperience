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

    function okClicked() {
        closeElement();
    }

    function cancelClicked() {
        page.showAlert(element, "Modifiche non salvate. Continuare?")
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

    function modalitySelected(obj) {
        modalityItem.description = obj.name
        var properties = {'objModel': obj}

        switch (obj.objectId) {
        case ThermalControlUnit99Zones.IdHoliday:
            itemLoader.setComponent(holidayComponent, properties)
            break
        case ThermalControlUnit99Zones.IdOff:
            itemLoader.setComponent(offComponent, properties)
            break
        case ThermalControlUnit99Zones.IdManual:
            itemLoader.setComponent(manualComponent, properties)
            break
        case ThermalControlUnit99Zones.IdAntifreeze:
            itemLoader.setComponent(antifreezeComponent, properties)
            break
        case ThermalControlUnit99Zones.IdWeeklyPrograms:
            itemLoader.setComponent(programsComponent, properties)
            break
        case ThermalControlUnit99Zones.IdVacation:
            itemLoader.setComponent(vacationComponent, properties)
            break
        case ThermalControlUnit99Zones.IdScenarios:
            itemLoader.setComponent(scenarioComponent, properties)
            break
        }
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
                property variant objModel

                ControlDateTime {
                    text: qsTr("attivo fino al")
                    date: Qt.formatDate(objModel.date, "dd/MM/yyyy")
                    time: Qt.formatTime(objModel.time, "hh:mm")
                }

                ControlUpDown {
                    id: programSelector
                    function scrollProgram(offset) {
                        var next = objModel.programIndex + offset
                        next = (next + objModel.programCount) % objModel.programCount
                        objModel.programIndex = next
                    }
                    onUpClicked: programSelector.scrollProgram(-1)
                    onDownClicked: programSelector.scrollProgram(1)
                    title: qsTr("programma successivo")
                    text: qsTr("settimanale ") + objModel.programDescription
                }

                ButtonOkCancel {
                    onCancelClicked: {
                        element.cancelClicked();
                        objModel.reset();
                    }

                    onOkClicked: {
                        element.okClicked()
                        objModel.apply()
                    }
                }
            }
        }

        Component {
            id: manualComponent
            Column {
                property variant objModel
                ControlMinusPlus {
                    title: qsTr("temperatura impostata")
                    text: objModel.temperature / 10 + "°C"
                    onMinusClicked: objModel.temperature -= 5
                    onPlusClicked: objModel.temperature += 5
                }

                ButtonOkCancel {
                    onCancelClicked: {
                        element.cancelClicked();
                        objModel.reset();
                    }
                    onOkClicked: {
                        element.okClicked()
                        objModel.apply()
                    }
                }
            }
        }

        Component {
            id: offComponent
            ButtonOkCancel {
                property variant objModel
                onCancelClicked: element.cancelClicked();
                onOkClicked: {
                    element.okClicked()
                    objModel.apply()
                }
            }
        }

        Component {
            id: antifreezeComponent
            ButtonOkCancel {
                property variant objModel
                onCancelClicked: element.cancelClicked();
                onOkClicked: {
                    element.okClicked()
                    objModel.apply()
                }
            }
        }

        Component {
            id: programsComponent
            Column {
                property variant objModel
                ControlUpDown {
                    id: programSelector
                    function scrollProgram(offset) {
                        var next = objModel.programIndex + offset
                        next = (next + objModel.programCount) % objModel.programCount
                        objModel.programIndex = next
                    }
                    onUpClicked: programSelector.scrollProgram(-1)
                    onDownClicked: programSelector.scrollProgram(1)
                    title: qsTr("selezionato")
                    text: objModel.programDescription
                }

                ButtonOkCancel {
                    onCancelClicked: element.cancelClicked();
                    onOkClicked: {
                        element.okClicked()
                        objModel.apply()
                    }
                }
            }
        }

        Component {
            id: vacationComponent
            Column {
                property variant objModel

                ControlDateTime {
                    text: qsTr("attivo fino al")
                    date: Qt.formatDate(objModel.date, "dd/MM/yyyy")
                    time: Qt.formatTime(objModel.time, "hh:mm")
                }

                ControlUpDown {
                    id: programSelector
                    function scrollProgram(offset) {
                        var next = objModel.programIndex + offset
                        next = (next + objModel.programCount) % objModel.programCount
                        objModel.programIndex = next
                    }
                    onUpClicked: programSelector.scrollProgram(-1)
                    onDownClicked: programSelector.scrollProgram(1)
                    title: qsTr("programma successivo")
                    text: qsTr("settimanale ") + objModel.programDescription
                }

                ButtonOkCancel {
                    onCancelClicked: {
                        element.cancelClicked();
                        objModel.reset();
                    }

                    onOkClicked: {
                        element.okClicked()
                        objModel.apply()
                    }
                }
            }
        }

        Component {
            id: scenarioComponent
            Column {
                property variant objModel
                ControlUpDown {
                    id: scenarioSelector
                    function scrollScenario(offset) {
                        var next = objModel.scenarioIndex + offset
                        next = (next + objModel.scenarioCount) % objModel.scenarioCount
                        objModel.scenarioIndex = next
                    }
                    onUpClicked: scenarioSelector.scrollScenario(-1)
                    onDownClicked: scenarioSelector.scrollScenario(1)
                    title: qsTr("selezionato")
                    text: qsTr("scenario ") + objModel.scenarioDescription
                }

                ButtonOkCancel {
                    onCancelClicked: element.cancelClicked();
                    onOkClicked: {
                        element.okClicked()
                        objModel.apply()
                    }
                }
            }
        }

        AnimatedLoader {
            id: itemLoader
            anchors.top: modalityItem.bottom
        }
    }
}
