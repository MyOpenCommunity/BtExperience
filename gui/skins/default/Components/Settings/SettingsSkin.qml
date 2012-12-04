import QtQuick 1.1
import BtObjects 1.0
import BtExperience 1.0
import Components 1.0
import "../../js/Stack.js" as Stack

MenuColumn {
    id: column

    width: 212
    height: Math.max(1, 50 * view.count)

    function alertOkClicked() {
        global.guiSettings.skin = privateProps.skin
        Stack.backToHome()
    }

    QtObject {
        id: privateProps
        property int skin
    }

    ListView {
        id: view
        currentIndex: global.guiSettings.skin
        anchors.fill: parent
        interactive: false
        delegate: MenuItemDelegate {
            name: pageObject.names.get('SKIN', modelData)
            onClicked: {
                privateProps.skin = modelData
                pageObject.showAlert(column, qsTr("Pressing ok will cause a device reboot in a few moments.\nPlease, do not use the touch till it is restarted.\nContinue?"))
            }
        }
        model: [GuiSettings.Clear,
                GuiSettings.Dark]
    }
}
