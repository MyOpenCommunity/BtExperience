import QtQuick 1.1
import BtObjects 1.0
import Components 1.0

MenuColumn {
    id: column

    property variant platform

    width: 212
    height: Math.max(1, 50 * ipConfigurationView.count)

    ListView {
        id: ipConfigurationView
        anchors.fill: parent
        interactive: false
        currentIndex: -1
        delegate: MenuItemDelegate {
            name: pageObject.names.get('CONFIG', modelData)
            isSelected: platform.lanConfig === modelData
            onDelegateTouched: {
                platform.lanConfig = modelData
                column.closeColumn()
            }
        }
        model: [PlatformSettings.Dhcp,
                PlatformSettings.Static]
    }
}
