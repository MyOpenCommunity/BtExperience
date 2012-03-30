import QtQuick 1.1
import BtObjects 1.0
import "logging.js" as Log


MenuElement {
    id: element

    // dimensions
    width: 212
    height: paginator.height

    // object model to retrieve network data
    ObjectModel {
        id: objectModel
        filters: [{objectId: ObjectInterface.IdGuiSettings}]
    }
    // TODO investigate why dataModel is not working as expected
    //dataModel: objectModel.getObject(0)

    // we don't have a ListView, so we don't have a currentIndex property: let's define it
    QtObject {
        id: privateProps
        property int currentIndex: -1
        // -1 -> no selection
        //  1 -> date menu
        //  2 -> time menu
        //  3 -> time zone menu
        //  4 -> daylight saving time menu
        // HACK dataModel is not working, so let's define a model property here
        // when dataModel work again, change all references!
        property variant model: objectModel.getObject(0)
    }

    onChildDestroyed: privateProps.currentIndex = -1

    // connects child signals to slots
    onChildLoaded: {
        if (child.dateChanged)
            child.dateChanged.connect(dateChanged)
        if (child.timeChanged)
            child.timeChanged.connect(timeChanged)
        if (child.timezoneChanged)
            child.timezoneChanged.connect(timezoneChanged)
        if (child.daylightSavingTimeChanged)
            child.daylightSavingTimeChanged.connect(daylightSavingTimeChanged)
    }

    function dateChanged(value) {
        privateProps.model.date = value;
    }
    function timeChanged(value, auto, format) {
        privateProps.model.time = value;
        privateProps.model.autoUpdate = auto
        privateProps.model.format = format
    }
    function timezoneChanged(value) {
        privateProps.model.timezone = value;
    }
    function daylightSavingTimeChanged(value) {
        privateProps.model.daylightSavingTime = value;
    }

    PaginatorColumn {
        id: paginator
        anchors.horizontalCenter: parent.horizontalCenter
        maxHeight: 350

        // date menu item (currentIndex === 1)
        MenuItem {
            id: dateItem
            name: qsTr("date")
            description: privateProps.model.date
            hasChild: true
            state: privateProps.currentIndex === 1 ? "selected" : ""
            onClicked: {
                if (privateProps.currentIndex !== 1)
                    privateProps.currentIndex = 1
                element.loadElement("", name)
            }
        }

        // time menu item (currentIndex === 2)
        MenuItem {
            id: timeItem
            name: qsTr("time")
            description: privateProps.model.time
            hasChild: true
            state: privateProps.currentIndex === 2 ? "selected" : ""
            onClicked: {
                if (privateProps.currentIndex !== 2)
                    privateProps.currentIndex = 2
                element.loadElement("Time.qml", name)
            }
        }

        // timezone menu item (currentIndex === 3)
        MenuItem {
            id: timezoneItem
            name: qsTr("timezone")
            description: pageObject.names.get('TIMEZONE', privateProps.model.timezone)
            hasChild: true
            state: privateProps.currentIndex === 3 ? "selected" : ""
            onClicked: {
                if (privateProps.currentIndex !== 3)
                    privateProps.currentIndex = 3
                element.loadElement("Timezone.qml", name)
            }
        }

        // daylight saving time menu item (currentIndex === 4)
        MenuItem {
            id: daylightSavingTimeItem
            name: qsTr("daylight saving time")
            description: pageObject.names.get('DST', privateProps.model.daylightSavingTime)
            hasChild: true
            state: privateProps.currentIndex === 4 ? "selected" : ""
            onClicked: {
                if (privateProps.currentIndex !== 4)
                    privateProps.currentIndex = 4
                element.loadElement("DaylightSavingTime.qml", name)
            }
        }
    }
}
