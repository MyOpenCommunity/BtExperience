import QtQuick 1.1
import BtObjects 1.0
import BtExperience 1.0
import Components 1.0
import "../../js/Stack.js" as Stack

MenuColumn {
    id: column

    function alertOkClicked() {
        global.keyboardLayout = privateProps.keyboardValue
        Stack.backToHome()
    }

    width: 212
    height: Math.max(1, 50 * view.count)

    ListView {
        id: view
        anchors.fill: parent
        interactive: false
        currentIndex: global.keyboardLayout === modelData
        delegate: MenuItemDelegate {
            name: pageObject.names.get('KEYBOARD', modelData)
            onClicked: {
                privateProps.keyboardValue = modelData
                pageObject.showAlert(column, qsTr("Pressing ok will cause a device reboot in a few moments.\nPlease, do not use the touch till it is restarted.\nContinue?"))
            }
        }
        model: global.keyboardLayouts
    }

    QtObject {
        id: privateProps
        property string keyboardValue
    }
}
