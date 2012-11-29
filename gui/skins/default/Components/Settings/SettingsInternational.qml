import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import "../../js/logging.js" as Log
import "../../js/Stack.js" as Stack


MenuColumn {
    id: column

    Component {
        id: textLanguage
        TextLanguage {}
    }

    Component {
        id: keyboardLanguage
        KeyboardLanguage {}
    }

    function alertOkClicked() {
        textLanguageItem.description = pageObject.names.get('LANGUAGE', privateProps.language);
        global.guiSettings.language = privateProps.language
        Stack.backToHome()
    }

    // we don't have a ListView, so we don't have a currentIndex property: let's define it
    QtObject {
        id: privateProps
        property int currentIndex: -1
        // -1 -> no selection
        //  1 -> text language menu
        //  2 -> keyboard language menu
        property string language: ''
    }

    onChildDestroyed: privateProps.currentIndex = -1

    // connects child signals to slots
    onChildLoaded: {
        if (child.textLanguageChanged)
            child.textLanguageChanged.connect(textLanguageChanged)
    }

    function textLanguageChanged(value) {
        // TODO assign to a model property
        //privateProps.model.TextLanguage = value;
        // TODO remove when model is implemented
        privateProps.language = value
        pageObject.showAlert(column, qsTr("Pressing ok will cause a device reboot as soon as possible.\nPlease, do not use the touch till it is restarted.\nContinue?"))
    }

    PaginatorColumn {
        id: paginator
        anchors.horizontalCenter: parent.horizontalCenter
        maxHeight: 300

        MenuItem {
            id: textLanguageItem
            name: qsTr("text language")
            description: pageObject.names.get('LANGUAGE', global.guiSettings.language)
            hasChild: true
            isSelected: privateProps.currentIndex === 1
            onClicked: {
                if (privateProps.currentIndex !== 1)
                    privateProps.currentIndex = 1
                column.loadColumn(textLanguage, name)
            }
        }

        MenuItem {
            id: keyboardLanguageItem
            name: qsTr("keyboard language")
            description: pageObject.names.get('KEYBOARD', global.keyboardLayout)
            hasChild: true
            isSelected: privateProps.currentIndex === 2
            onClicked: {
                if (privateProps.currentIndex !== 2)
                    privateProps.currentIndex = 2
                column.loadColumn(keyboardLanguage, name)
            }
        }
    }
}
