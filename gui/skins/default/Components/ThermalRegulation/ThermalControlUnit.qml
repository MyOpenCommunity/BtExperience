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
    }

    Component {
        id: thermalControlUnitSeasons
        ThermalControlUnitSeasons {}
    }

    Component {
        id: thermalControlUnitModalities
        ThermalControlUnitModalities {}
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

        Image {
            id: fixedItem
            anchors.top: parent.top
            width: parent.width
            height: visible ? 50 : 0
            // 4 zones central units are zones themselves: we must show the
            // temperature of the linked probe in such cases
            visible: (!is99zones)
            source: "../../images/common/bg_UnaRegolazione.png"

            UbuntuLightText {
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
                        if (privateProps.currentElement !== -1)
                            resetSelection()
                    }

                    Component.onCompleted: {
                        column.childDestroyed.connect(resetSelection)
                        privateProps.currentElementChanged.connect(checkReset)
                    }

                    onDateClicked: {
                        column.loadColumn(dateSelect, qsTr("date"), objModel, {"twoFields": false})
                        privateProps.currentElement = -1
                    }

                    onTimeClicked: {
                        column.loadColumn(dateSelect, qsTr("time"), objModel, {"twoFields": true})
                        privateProps.currentElement = -1
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
                    DateSelect {
                    }
                }

                ControlDateTime {
                    id: dateTimeTimed
                    text: qsTr("duration")
                    time: DateTime.format(objModel.date)["time"]
                    // in timed mode we can set only the end time, no date setting
                    dateVisible: false

                    function checkReset() {
                        if (privateProps.currentElement !== -1)
                            resetSelection()
                    }

                    Component.onCompleted: {
                        column.childDestroyed.connect(resetSelection)
                        privateProps.currentElementChanged.connect(checkReset)
                    }

                    onTimeClicked: {
                        column.loadColumn(dateSelectTimed, qsTr("time"), objModel, {"twoFields": true})
                        privateProps.currentElement = -1
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
                        if (privateProps.currentElement !== -1)
                            resetSelection()
                    }

                    Component.onCompleted: {
                        column.childDestroyed.connect(resetSelection)
                        privateProps.currentElementChanged.connect(checkReset)
                    }

                    onDateClicked: {
                        column.loadColumn(dateSelectWorking, qsTr("date"), objModel, {"twoFields": false})
                        privateProps.currentElement = -1
                    }

                    onTimeClicked: {
                        column.loadColumn(dateSelectWorking, qsTr("time"), objModel, {"twoFields": true})
                        privateProps.currentElement = -1
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
