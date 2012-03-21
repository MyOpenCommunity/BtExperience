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
        pageObject.showAlert(element, qsTr("unsaved changes. continue?"))
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
            name: qsTr("season")
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
            name: qsTr("mode")
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
                    text: qsTr("valid until")
                    date: Qt.formatDate(objModel.date, "dd/MM/yyyy")
                    time: Qt.formatTime(objModel.time, "hh:mm")
                }

                MenuItem {
                    name: qsTr("next program")
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
            id: manualComponent
            Column {
                property variant objModel
                ControlMinusPlus {
                    title: qsTr("temperature set")
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
                    name: qsTr("next program")
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
                    text: qsTr("valid until")
                    date: Qt.formatDate(objModel.date, "dd/MM/yyyy")
                    time: Qt.formatTime(objModel.time, "hh:mm")
                }

                MenuItem {
                    name: qsTr("next program")
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
            id: scenarioComponent
            Column {
                property variant objModel

                MenuItem {
                    name: qsTr("next scenario")
                    description: objModel.scenarioDescription
                    hasChild: true
                    active: element.animationRunning === false
                    state: privateProps.currentElement === 3 ? "selected" : ""
                    onClicked: {
                        element.loadElement("ThermalControlUnitScenarios.qml", qsTr("scenarios"), objModel)
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

        AnimatedLoader {
            id: itemLoader
            anchors.top: modalityItem.bottom
        }
    }
}
