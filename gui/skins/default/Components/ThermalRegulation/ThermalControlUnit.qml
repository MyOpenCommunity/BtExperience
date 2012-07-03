import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Text 1.0
import "../../js/datetime.js" as DateTime


MenuColumn {
    id: column

    property int is99zones: (dataModel.objectId === ObjectInterface.IdThermalControlUnit99)

    ObjectModel {
        id: centralProbe
        filters: [
            {objectId: ObjectInterface.IdThermalControlledProbe, objectKey: column.dataModel.objectKey},
            {objectId: ObjectInterface.IdThermalControlledProbeFancoil, objectKey: column.dataModel.objectKey}
        ]
        onModelReset: fixedItem.temperature = getObject(0).temperature
    }

    Component {
        id: thermalControlUnitSeasons
        ThermalControlUnitSeasons {}
    }

    Component {
        id: thermalControlUnitModalities
        ThermalControlUnitModalities {}
    }

    height: fixedItem.height + seasonItem.height + modalityItem.height + itemLoader.height

    QtObject {
        id: privateProps
        property int currentElement: -1
        property int pendingSeason: -1

        function getDateTime(objModel) {
            var m = objModel.months
            if (m === undefined)
                m = 1
            var d = objModel.days
            if (d === undefined)
                d = 1
            var y = objModel.years
            if (y === undefined)
                y = 2012
            var dt = new Date(m+"/"+d+"/"+y)
            dt.setHours(objModel.hours)
            dt.setMinutes(objModel.minutes)
            dt.setSeconds(objModel.seconds)
            return dt
        }
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

    onChildDestroyed: privateProps.currentElement = -1

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
        case ThermalControlUnit.IdHoliday:
            itemLoader.setComponent(holidayComponent, properties)
            break
        case ThermalControlUnit.IdOff:
            itemLoader.setComponent(offComponent, properties)
            break
        case ThermalControlUnit.IdManual:
            itemLoader.setComponent(manualComponent, properties)
            break
        case ThermalControlUnit.IdAntifreeze:
            itemLoader.setComponent(antifreezeComponent, properties)
            break
        case ThermalControlUnit.IdWeeklyPrograms:
            itemLoader.setComponent(programsComponent, properties)
            break
        case ThermalControlUnit.IdWorking:
            itemLoader.setComponent(workingComponent, properties)
            break
        case ThermalControlUnit.IdScenarios:
            itemLoader.setComponent(scenarioComponent, properties)
            break
        case ThermalControlUnit.IdTimedManual:
            itemLoader.setComponent(timedComponent, properties)
            break
        }
    }

    Item {
        id: mainItem
        width: 212
        height: 326
        anchors.fill: parent

        ControlTemperature {
            id: fixedItem
            property int temperature: 0
            anchors.top: parent.top
            // 4 zones central units are zones themselves: we must show the
            // temperature of the linked probe in such cases
            visible: (!is99zones)
            // trick to compute the right height for menu column
            onVisibleChanged: if (!visible) height = 0
            text: (fixedItem.temperature / 10).toFixed(1) + qsTr("°C")
        }

        MenuItem {
            id: seasonItem
            hasChild: true
            anchors.top: fixedItem.bottom
            name: qsTr("season")
            isSelected: privateProps.currentElement === 1
            onClicked: {
                if (privateProps.currentElement !== 1)
                    privateProps.currentElement = 1
                column.loadColumn(thermalControlUnitSeasons, seasonItem.name, column.dataModel)
            }
        }

        MenuItem {
            id: modalityItem
            hasChild: true
            anchors.top: seasonItem.bottom
            name: qsTr("mode")
            isSelected: privateProps.currentElement === 2
            onClicked: {
                column.loadColumn(thermalControlUnitModalities, modalityItem.name, column.dataModel)
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
                    id: dateSelectHoliday
                    DateSelect {}
                }

                ControlSetDateTime {
                    date: DateTime.format(privateProps.getDateTime(objModel))["date"]
                    time: DateTime.format(privateProps.getDateTime(objModel))["time"]
                    status: (privateProps.currentElement === 3) ? 1 : 0

                    onEditClicked: {
                        if (privateProps.currentElement !== 3)
                            privateProps.currentElement = 3
                        column.loadColumn(dateSelectHoliday, column.title, objModel)
                    }
                }

                ControlLeftRightWithTitle {
                    title: qsTr("next program")
                    text: objModel.programDescription
                    onLeftClicked: objModel.programIndex -= 1
                    onRightClicked: objModel.programIndex += 1
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
                    text: (objModel.temperature / 10).toFixed(1) + qsTr("°C")
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

                ControlLeftRightWithTitle {
                    title: qsTr("next program")
                    text: objModel.programDescription
                    onLeftClicked: objModel.programIndex -= 1
                    onRightClicked: objModel.programIndex += 1
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
                    DateSelect {}
                }

                ControlSetDateTime {
                    dateVisible: false
                    source: "../../images/termo/4-zone_temporizzato/bg_imposta-ora.svg"
                    date: DateTime.format(privateProps.getDateTime(objModel))["date"]
                    time: DateTime.format(privateProps.getDateTime(objModel))["time"]
                    status: (privateProps.currentElement === 3) ? 1 : 0

                    onEditClicked: {
                        if (privateProps.currentElement !== 3)
                            privateProps.currentElement = 3
                        // I don't know why, but here we need only ../ and not ../../
                        column.loadColumn(dateSelectTimed, column.title, objModel, {dateVisible: false, source: "../images/termo/4-zone_temporizzato/bg_comando-ora.svg"})
                    }
                }

                ControlMinusPlus {
                    title: qsTr("temperature set")
                    text: (objModel.temperature / 10).toFixed(1) + qsTr("°C")
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
                    DateSelect {}
                }

                ControlSetDateTime {
                    date: DateTime.format(privateProps.getDateTime(objModel))["date"]
                    time: DateTime.format(privateProps.getDateTime(objModel))["time"]
                    status: (privateProps.currentElement === 3) ? 1 : 0

                    onEditClicked: {
                        if (privateProps.currentElement !== 3)
                            privateProps.currentElement = 3
                        column.loadColumn(dateSelectWorking, column.title, objModel)
                    }
                }

                ControlLeftRightWithTitle {
                    title: qsTr("next program")
                    text: objModel.programDescription
                    onLeftClicked: objModel.programIndex -= 1
                    onRightClicked: objModel.programIndex += 1
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

                ControlLeftRightWithTitle {
                    title: qsTr("next scenario")
                    text: objModel.scenarioDescription
                    onLeftClicked: objModel.scenarioIndex -= 1
                    onRightClicked: objModel.scenarioIndex += 1
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
