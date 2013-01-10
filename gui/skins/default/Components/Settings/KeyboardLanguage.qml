import QtQuick 1.1
import BtObjects 1.0
import BtExperience 1.0
import Components 1.0
import "../../js/Stack.js" as Stack

MenuColumn {
    id: column

    signal keyboardLayoutChanged(string config)

    width: 212
    height: Math.max(1, 50 * view.count)

    ListView {
        id: view
        anchors.fill: parent
        interactive: false
        delegate: MenuItem {
            name: pageObject.names.get('KEYBOARD', modelData)
            isSelected: global.keyboardLayout === modelData
            onClicked: keyboardLayoutChanged(modelData)
        }
        model: global.keyboardLayouts
    }
}
