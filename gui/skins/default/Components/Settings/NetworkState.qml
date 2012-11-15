import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: column

    property variant platform

    width: 212
    height: Math.max(1, 50 * networkStateView.count)

    ListView {
        id: networkStateView
        anchors.fill: parent
        interactive: false
        currentIndex: -1
        delegate: MenuItemDelegate {
            name: pageObject.names.get('STATE', modelData)
            isSelected: platform.lanStatus === modelData
            onClicked: {
                platform.lanStatus = modelData
                column.closeColumn()
            }
        }
        model: [PlatformSettings.Disabled,
                PlatformSettings.Enabled]
    }
}
