import QtQuick 1.1
import BtObjects 1.0
import Components 1.0


MenuColumn {
    id: column

    QtObject {
        id: privateProps
        property int currentIndex: global.keepingHistory ? 1 : 2
    }

    onChildDestroyed: {
        privateProps.currentIndex = -1
    }

    Column {
        MenuItem {
            name: qsTr("enable")
            isSelected: privateProps.currentIndex === 1
            onClicked: {
                if (privateProps.currentIndex !== 1)
                    privateProps.currentIndex = 1
                global.keepingHistory = true
            }
        }

        MenuItem {
            name: qsTr("disable")
            isSelected: privateProps.currentIndex === 2
            onClicked: {
                if (privateProps.currentIndex !== 2)
                    privateProps.currentIndex = 2
                global.keepingHistory = false
            }
        }
    }
}
