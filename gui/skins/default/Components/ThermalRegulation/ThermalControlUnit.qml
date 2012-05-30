import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

import "../../js/datetime.js" as DateTime


MenuColumn {
    id: column

    property int zones: 99 // 99 - 99 zones, 4 - 4 zones central unit

    FilterListModel {
        id: centralProbe
        // NOTE in case the central is 4 zones we must retrieve the temperature
        // from the associated probe; we don't know if the probe is with or
        // without fancoil; we look for both cases: one will return the probe,
        // the other will not return anything
        filters: [
            {objectId: ObjectInterface.IdThermalControlledProbe, objectKey: column.dataModel.objectKey},
            {objectId: ObjectInterface.IdThermalControlledProbeFancoil, objectKey: column.dataModel.objectKey}
        ]
    }

    Component {
        id: thermalControlUnitSeasons
        ThermalControlUnitSeasons {}
    }

    Component {
        id: thermalControlUnitModalities
        ThermalControlUnitModalities {}
    }

    Component {
        id: thermalControlUnitPrograms
        ThermalControlUnitPrograms {}
    }

    Component {
        id: thermalControlUnitScenarios
        ThermalControlUnitScenarios {}
    }

    width: 212
    height: seasonItem.height + modalityItem.height + itemLoader.height

    QtObject {
        id: privateProps
        property int currentElement: -1
        property int pendingSeason: -1
    }

    function okClicked() {
        closeColumn()
        if (privateProps.pendingSeason !== -1) {
            dataModel.season = privateProps.pendingSeason
            privateProps.pendingSeason = -1
        }
    }

    function cancelClicked() {
        pageObject.showAlert(column, qsTr("unsaved changes. continue?"))
    }

    function alertOkClicked() {
        column.closeColumn()
    }

    onChildLoaded: {
        if (child.modalitySelected)
            child.modalitySelected.connect(modalitySelected)
        if (child.seasonSelected)
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
        case ThermalControlUnit99Zones.IdWorking:
            itemLoader.setComponent(workingComponent, properties)
            break
        case ThermalControlUnit99Zones.IdScenarios:
            itemLoader.setComponent(scenarioComponent, properties)
            break
        case ThermalControlUnit99Zones.IdTimedManual:
            itemLoader.setComponent(timedComponent, properties)
            break
        }
    }


    Item {
        id: mainItem
        width: 212
        height: 326
        anchors.fill: parent

        Image {
            id: fixedItem
            anchors.top: parent.top
            width: parent.width
            height: visible ? 50 : 0
            // 4 zones central units are zones themselves: we must show the
            // temperature of the linked probe in such cases
            visible: (zones === 4)
            source: "../../images/common/bg_UnaRegolazione.png"

            Text {
                id: textTemperature
                anchors.centerIn: parent
                text: centralProbe.getObject(0).temperature  / 10 + qsTr("°C")
                font.pixelSize: 24
            }
        }

        MenuItem {
            id: seasonItem
            hasChild: true
            anchors.top: fixedItem.bottom
            name: qsTr("season")
            state: privateProps.currentElement === 1 ? "selected" : ""

            onClicked: {
                column.loadColumn(
                            thermalControlUnitSeasons,
                            seasonItem.name,
                            column.dataModel)
                if (privateProps.currentElement !== 1)
                    privateProps.currentElement = 1
            }
        }

        MenuItem {
            id: modalityItem
            hasChild: true
            anchors.top: seasonItem.bottom
            name: qsTr("mode")
            state: privateProps.currentElement === 2 ? "selected" : ""

            onClicked: {
                column.loadColumn(
                            thermalControlUnitModalities,
                            modalityItem.name,
                            column.dataModel)
                if (privateProps.currentElement !== 2)
                    privateProps.currentElement = 2
            }
        }

        Component {
            id: holidayComponent
            Column {
                id: holidayColumn
                property variant objModel

                Component {
                    id: dateSelect
                    DateSelect {
                    }
                }

                ControlDateTime {
                    id: dateTime
                    text: qsTr("valid until")
                    date: DateTime.format(objModel.date)["date"]
                    time: DateTime.format(objModel.date)["time"]

                    function checkReset() {
                        if (column.privateProps.currentElement !== -1)
                            resetSelection()
                    }

                    Component.onCompleted: {
                        column.childDestroyed.connect(resetSelection)
                        column.privateProps.currentElementChanged.connect(checkReset)
                    }

                    onDateClicked: {
                        column.loadColumn(dateSelect, qsTr("date"), objModel, {"twoFields": false})
                        column.privateProps.currentElement = -1
                    }

                    onTimeClicked: {
                        column.loadColumn(dateSelect, qsTr("time"), objModel, {"twoFields": true})
                        column.privateProps.currentElement = -1
                    }
                }

                MenuItem {
                    name: qsTr("next program")
                    description: objModel.programDescription
                    hasChild: true
                    state: privateProps.currentElement === 3 ? "selected" : ""
                    onClicked: {
                        column.loadColumn(
                                    thermalControlUnitPrograms,
                                    qsTr("programs"),
                                    objModel)
                        if (privateProps.currentElement !== 3)
                            privateProps.currentElement = 3
                    }
                }

                ButtonOkCancel {
                    onCancelClicked: {
                        column.cancelClicked()
                        objModel.reset()
                    }

                    onOkClicked: {
                        column.okClicked()
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
                        column.cancelClicked()
                        objModel.reset()
                    }
                    onOkClicked: {
                        column.okClicked()
                        objModel.apply()
                    }
                }
            }
        }

        Component {
            id: offComponent
            ButtonOkCancel {
                property variant objModel
                onCancelClicked: column.cancelClicked() // Nothing to reset
                onOkClicked: {
                    column.okClicked()
                    objModel.apply()
                }
            }
        }

        Component {
            id: antifreezeComponent
            ButtonOkCancel {
                property variant objModel
                onCancelClicked: column.cancelClicked() // Nothing to reset
                onOkClicked: {
                    column.okClicked()
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
                    state: privateProps.currentElement === 3 ? "selected" : ""
                    onClicked: {
                        column.loadColumn(
                                    thermalControlUnitPrograms,
                                    qsTr("programs"),
                                    objModel)
                        if (privateProps.currentElement !== 3)
                            privateProps.currentElement = 3
                    }
                }

                ButtonOkCancel {
                    onCancelClicked: {
                        column.cancelClicked()
                        objModel.reset()
                    }
                    onOkClicked: {
                        column.okClicked()
                        objModel.apply()
                    }
                }
            }
        }

        Component {
            id: timedComponent
            Column {
                property variant objModel

                Component {
                    id: dateSelectTimed
                    DateSelect {
                    }
                }

                ControlDateTime {
                    id: dateTimeTimed
                    text: qsTr("valid until")
                    time: DateTime.format(objModel.date)["time"]
                    // in timed mode we can set only the end time, no date setting
                    dateVisible: false

                    function checkReset() {
                        if (column.privateProps.currentElement !== -1)
                            resetSelection()
                    }

                    Component.onCompleted: {
                        column.childDestroyed.connect(resetSelection)
                        column.privateProps.currentElementChanged.connect(checkReset)
                    }

                    onTimeClicked: {
                        column.loadColumn(dateSelectTimed, qsTr("time"), objModel, {"twoFields": true})
                        column.privateProps.currentElement = -1
                    }
                }

                ControlMinusPlus {
                    title: qsTr("temperature set")
                    text: objModel.temperature / 10 + "°C"
                    onMinusClicked: objModel.temperature -= 5
                    onPlusClicked: objModel.temperature += 5
                }

                ButtonOkCancel {
                    onCancelClicked: {
                        column.cancelClicked()
                        objModel.reset()
                    }
                    onOkClicked: {
                        column.okClicked()
                        objModel.apply()
                    }
                }
            }
        }

        Component {
            id: workingComponent
            Column {
                property variant objModel

                Component {
                    id: dateSelectWorking
                    DateSelect {
                    }
                }

                ControlDateTime {
                    id: dateTimeWorking
                    text: qsTr("valid until")
                    date: DateTime.format(objModel.date)["date"]
                    time: DateTime.format(objModel.date)["time"]

                    function checkReset() {
                        if (column.privateProps.currentElement !== -1)
                            resetSelection()
                    }

                    Component.onCompleted: {
                        column.childDestroyed.connect(resetSelection)
                        column.privateProps.currentElementChanged.connect(checkReset)
                    }

                    onDateClicked: {
                        column.loadColumn(dateSelectWorking, qsTr("date"), objModel, {"twoFields": false})
                        column.privateProps.currentElement = -1
                    }

                    onTimeClicked: {
                        column.loadColumn(dateSelectWorking, qsTr("time"), objModel, {"twoFields": true})
                        column.privateProps.currentElement = -1
                    }
                }

                MenuItem {
                    name: qsTr("next program")
                    description: objModel.programDescription
                    hasChild: true
                    state: privateProps.currentElement === 3 ? "selected" : ""
                    onClicked: {
                        column.loadColumn(
                                    thermalControlUnitPrograms,
                                    qsTr("programs"),
                                    objModel)
                        if (privateProps.currentElement !== 3)
                            privateProps.currentElement = 3
                    }
                }

                ButtonOkCancel {
                    onCancelClicked: {
                        column.cancelClicked()
                        objModel.reset()
                    }

                    onOkClicked: {
                        column.okClicked()
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
                    state: privateProps.currentElement === 3 ? "selected" : ""
                    onClicked: {
                        column.loadColumn(
                                    thermalControlUnitScenarios,
                                    qsTr("scenarios"),
                                    objModel)
                        if (privateProps.currentElement !== 3)
                            privateProps.currentElement = 3
                    }
                }

                ButtonOkCancel {
                    onCancelClicked: {
                        column.cancelClicked()
                        objModel.reset()
                    }
                    onOkClicked: {
                        column.okClicked()
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
