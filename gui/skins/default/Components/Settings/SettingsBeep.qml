import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: column

    width: 212
    height: Math.max(1, 50 * view.count)

    ListView {
        id: view
        anchors.fill: parent
        interactive: false
        currentIndex: -1
        delegate: MenuItemDelegate {
            name: pageObject.names.get('BEEP', modelData)
            isSelected: global.guiSettings.beep === modelData
            onClicked: global.guiSettings.beep = modelData
        }
        model: [true, false]
    }
}
