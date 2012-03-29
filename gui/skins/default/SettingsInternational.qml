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
        //  1 -> text language menu
        //  2 -> keyboard language menu
        //  3 -> temperature menu
        //  4 -> unit system
        //  5 -> currency
        //  6 -> number separators
        // HACK dataModel is not working, so let's define a model property here
        // when dataModel work again, change all references!
        property variant model: objectModel.getObject(0)
    }

    onChildDestroyed: privateProps.currentIndex = -1

    // connects child signals to slots
    onChildLoaded: {
        if (child.textLanguageChanged)
            child.textLanguageChanged.connect(textLanguageChanged)
        if (child.keyboardLanguageChanged)
            child.keyboardLanguageChanged.connect(keyboardLanguageChanged)
        if (child.temperatureChanged)
            child.temperatureChanged.connect(temperatureChanged)
        if (child.unitSystemChanged)
            child.unitSystemChanged.connect(unitSystemChanged)
        if (child.currencyChanged)
            child.currencyChanged.connect(currencyChanged)
        if (child.numberSeparatorsChanged)
            child.numberSeparatorsChanged.connect(numberSeparatorsChanged)
    }

    function textLanguageChanged(value) {
        // TODO assign to a model property
        //privateProps.model.TextLanguage = value;
        // TODO remove when model is implemented
        textLanguageItem.description = pageObject.names.get('LANGUAGE', value);
    }
    function keyboardLanguageChanged(value) {
        // TODO assign to a model property
        //privateProps.model.TextLanguage = value;
        // TODO remove when model is implemented
        keyboardLanguageItem.description = pageObject.names.get('LANGUAGE', value);
    }
    function temperatureChanged(value) {
        // TODO assign to a model property
        //privateProps.model.Temperature = value;
        // TODO remove when model is implemented
        temperatureItem.description = pageObject.names.get('LANGUAGE', value)
    }
    function unitSystemChanged(value) {
        // TODO assign to a model property
        //privateProps.model.UnitSystem = value;
        // TODO remove when model is implemented
        unitSystemItem.description = pageObject.names.get('LANGUAGE', value)
    }
    function currencyChanged(value) {
        // TODO assign to a model property
        //privateProps.model.Currency = value;
        // TODO remove when model is implemented
        currencyItem.description = pageObject.names.get('LANGUAGE', value)
    }
    function numberSeparatorsChanged(value) {
        // TODO assign to a model property
        //privateProps.model.NumberSeparator = value;
        // TODO remove when model is implemented
        numberSeparatorsItem.description = pageObject.names.get('LANGUAGE', value)
    }

    PaginatorColumn {
        id: paginator
        anchors.horizontalCenter: parent.horizontalCenter
        maxHeight: 300

        // TODO international menu is to be defined: this is a very skeletal
        // starting point
        MenuItem {
            id: textLanguageItem
            name: qsTr("text language")
            description: pageObject.names.get('LANGUAGE', 0)
            hasChild: true
            state: privateProps.currentIndex === 1 ? "selected" : ""
            onClicked: {
                if (privateProps.currentIndex !== 1)
                    privateProps.currentIndex = 1
                element.loadElement("TextLanguage.qml", name)
            }
        }
        MenuItem {
            id: keyboardLanguageItem
            name: qsTr("keyboard language")
            description: pageObject.names.get('LANGUAGE', 0)
            hasChild: true
            state: privateProps.currentIndex === 2 ? "selected" : ""
            onClicked: {
                if (privateProps.currentIndex !== 2)
                    privateProps.currentIndex = 2
                element.loadElement("KeyboardLanguage.qml", name)
            }
        }
        MenuItem {
            id: temperatureItem
            name: qsTr("temperature")
            description: "°C"
            hasChild: true
            state: privateProps.currentIndex === 3 ? "selected" : ""
            onClicked: {
                if (privateProps.currentIndex !== 3)
                    privateProps.currentIndex = 3
                element.loadElement("", name)
            }
        }
        MenuItem {
            id: unitSystemItem
            name: qsTr("unit system")
            description: "metric"
            hasChild: true
            state: privateProps.currentIndex === 4 ? "selected" : ""
            onClicked: {
                if (privateProps.currentIndex !== 4)
                    privateProps.currentIndex = 4
                element.loadElement("", name)
            }
        }
        MenuItem {
            id: currencyItem
            name: qsTr("currency")
            description: "euro €"
            hasChild: true
            state: privateProps.currentIndex === 5 ? "selected" : ""
            onClicked: {
                if (privateProps.currentIndex !== 5)
                    privateProps.currentIndex = 5
                element.loadElement("", name)
            }
        }
        MenuItem {
            id: numberSeparatorItem
            name: qsTr("number separator")
            description: "0.000,00"
            hasChild: true
            state: privateProps.currentIndex === 6 ? "selected" : ""
            onClicked: {
                if (privateProps.currentIndex !== 6)
                    privateProps.currentIndex = 6
                element.loadElement("", name)
            }
        }
    }
}
