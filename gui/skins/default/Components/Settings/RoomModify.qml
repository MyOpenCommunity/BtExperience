import QtQuick 1.1
import BtObjects 1.0
import "../../js/Stack.js" as Stack
import Components 1.0

MenuColumn {
    id: column

    onChildDestroyed: privateProps.currentIndex = -1

    Column {
        MenuItem {
            name: qsTr("Modify card image")
            isSelected: privateProps.currentIndex === 1
            onClicked: {
                if (privateProps.currentIndex !== 1)
                    privateProps.currentIndex = 1
                Stack.pushPage("NewProfileCard.qml", {"profile": column.dataModel})
            }
        }

        MenuItem {
            name: qsTr("Modify background image")
            isSelected: privateProps.currentIndex === 2
            onClicked: {
                if (privateProps.currentIndex !== 2)
                    privateProps.currentIndex = 2
                console.log("Implement modify background image feature")
            }
        }
    }

    QtObject {
        id: privateProps
        property int currentIndex: -1
    }
}
