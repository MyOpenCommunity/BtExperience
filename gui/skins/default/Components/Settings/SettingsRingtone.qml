import QtQuick 1.1
import BtObjects 1.0
import BtExperience 1.0
import Components 1.0


MenuColumn {
    id: column

    property int type

    // using a ListView, so I have to hardcode dim
    height: 350
    width: 212

    onChildDestroyed: {
        itemList.currentIndex = -1
    }

    ListView {
        id: itemList

        anchors.fill: parent
        currentIndex: -1
        interactive: false

        delegate: MenuItemDelegate {
            name: modelData.replace(/^.*[\\\/]/, '').split(".").shift() // some JS magic
            hasChild: false
            isSelected: modelData === global.ringtoneManager.ringtoneFromType(column.type)
            onClicked: {
                global.ringtoneManager.setRingtoneFromTypeRingtone(column.type, modelData)
                column.closeColumn()
            }
        }

        model: global.ringtoneManager.ringtoneList()
    }
}
