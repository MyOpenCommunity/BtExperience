import QtQuick 1.1
import BtObjects 1.0


MenuElement {
    id: element
    width: 212
    height: seasonItem.height + modalityItem.height + itemLoader.height

    QtObject {
        id: privateProps
        property int currentElement: -1
        property int pendingSeason: -1
    }

    function okClicked() {
        closeElement()
        if (privateProps.pendingSeason !== -1) {
            dataModel.season = privateProps.pendingSeason
            privateProps.pendingSeason = -1
        }
    }

    function cancelClicked() {
        pageObject.showAlert(element, "Modifiche non salvate. Continuare?")
    }

    function alertOkClicked() {
        element.closeElement()
    }

    onChildLoaded: {
        if (child.modalitySelected)
            child.modalitySelected.connect(modalitySelected)
        else if (child.seasonSelected)
            child.seasonSelected.connect(seasonSelected)
    }

    onChildDestroyed: {
        privateProps.currentElement = -1
    }

    Connections {
        target: dataModel
        onCurrentModalityChanged: {
            if (dataModel.currentModality)
                modalitySelected(dataModel.currentModality)
        }
    }

    Connections {
        target: dataModel
        onSeasonChanged: {
            seasonItem.description = pageObject.names.get('SEASON', season)
        }
    }

    Component.onCompleted: {
        if (dataModel.currentModality)
            modalitySelected(dataModel.currentModality)

        seasonItem.description = pageObject.names.get('SEASON', dataModel.season)
    }

    function seasonSelected(season) {
        seasonItem.description = pageObject.names.get('SEASON', season)
        privateProps.pendingSeason = season
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
            hasChild: true
            active: element.animationRunning === false
            anchors.top: parent.top
            name: qsTr("funzionamento")
            state: privateProps.currentElement === 1 ? "selected" : ""

            onClicked: {
                element.loadElement("ThermalControlUnitSeasons.qml", seasonItem.name, element.dataModel)
                if (privateProps.currentElement !== 1)
                    privateProps.currentElement = 1
            }
        }

        MenuItem {
            id: modalityItem
            hasChild: true
            active: element.animationRunning === false
            anchors.top: seasonItem.bottom
            name: qsTr("modalità")
            state: privateProps.currentElement === 2 ? "selected" : ""

            onClicked: {
                element.loadElement("ThermalControlUnitModalities.qml", modalityItem.name, element.dataModel)
                if (privateProps.currentElement !== 2)
                    privateProps.currentElement = 2
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
                        element.cancelClicked()
                        objModel.reset()
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
                        element.cancelClicked()
                        objModel.reset()
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
                onCancelClicked: element.cancelClicked() // Nothing to reset
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
                onCancelClicked: element.cancelClicked() // Nothing to reset
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

                MenuItem {
                    name: qsTr("Next program")
                    description: objModel.programDescription
                    hasChild: true
                    active: element.animationRunning === false
                    state: privateProps.currentElement === 3 ? "selected" : ""
                    onClicked: {
                        element.loadElement("ThermalControlUnitPrograms.qml", qsTr("programs"), objModel)
                        if (privateProps.currentElement !== 3)
                            privateProps.currentElement = 3
                    }
                }

                ButtonOkCancel {
                    onCancelClicked: {
                        element.cancelClicked()
                        objModel.reset()
                    }
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
                        element.cancelClicked()
                        objModel.reset()
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
                    onCancelClicked: {
                        element.cancelClicked()
                        objModel.reset()
                    }
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
