import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import "../../js/logging.js" as Log
import "../../js/Stack.js" as Stack
import "../../js/EventManager.js" as EventManager


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
        if (privateProps.currentIndex === 1)
            global.guiSettings.language = privateProps.language
        else if (privateProps.currentIndex === 2)
            global.keyboardLayout = privateProps.keyboardLayout

        EventManager.eventManager.notificationsEnabled = false
        Stack.backToHome({state: "pageLoading"})
    }

    // we don't have a ListView, so we don't have a currentIndex property: let's define it
    QtObject {
        id: privateProps
        property int currentIndex: -1
        // -1 -> no selection
        //  1 -> text language menu
        //  2 -> keyboard language menu
        property string language: ''
        property string keyboardLayout: ""

        function showAlert() {
            pageObject.installPopup(alertComponent, {"message": pageObject.names.get('REBOOT', 0), "source": column})
        }
    }

    Component {
        id: alertComponent
        Alert {}
    }

    onChildDestroyed: privateProps.currentIndex = -1
    Connections {
        target: column.child
        ignoreUnknownSignals: true

        // The if() below is needed: we want to avoid going into 'wait for reboot'
        // state in case the C++ property doesn't change value and conf.xml is
        // not written
        onTextLanguageChanged: {
            if (global.guiSettings.language !== config) {
                privateProps.language = config
                privateProps.showAlert()
            }
        }
        onKeyboardLayoutChanged: {
            if (global.keyboardLayout !== config) {
                privateProps.keyboardLayout = config
                privateProps.showAlert()
            }
        }
    }

    Column {
        MenuItem {
            id: textLanguageItem
            name: qsTr("text language")
            description: pageObject.names.get('LANGUAGE', global.guiSettings.language)
            hasChild: true
            isSelected: privateProps.currentIndex === 1
            onTouched: {
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
            onTouched: {
                if (privateProps.currentIndex !== 2)
                    privateProps.currentIndex = 2
                column.loadColumn(keyboardLanguage, name)
            }
        }
    }
}
