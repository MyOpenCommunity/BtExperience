import QtQuick 1.1
import BtObjects 1.0
import Components 1.0


MenuColumn {
    id: column

    QtObject {
        id: privateProps
        property int currentIndex: -1
    }

    onChildDestroyed: {
        privateProps.currentIndex = -1
    }

    function alertOkClicked() {
        global.deleteHistory()
    }

    Column {
        MenuItem {
            id: homePageItem
            name: qsTr("Change Home Page")
            onTouched: {
                if (privateProps.currentIndex !== 1)
                    privateProps.currentIndex = 1
                column.closeChild()
                installPopup(popupEditUrl)
                pageObject.popupLoader.item.setInitialText(global.homePageUrl)
            }
            Component {
                id: popupEditUrl
                EditNote {
                    title: qsTr("Insert new home page")
                    onOkClicked: global.homePageUrl = text
                }
            }
        }

        MenuItem {
            id: historyItem
            name: qsTr("Enable history")
            description: global.keepingHistory ? qsTr("Enabled") : qsTr("Disabled")
            hasChild: true
            isSelected: privateProps.currentIndex === 2
            onTouched: {
                if (privateProps.currentIndex !== 2)
                    privateProps.currentIndex = 2
                column.loadColumn(historyComponent, name)
            }

            Component {
                id: historyComponent
                SettingsHistory {
                }
            }
        }

        MenuItem {
            id: clearHistoryItem
            name: qsTr("Clear History")
            onTouched: {
                if (privateProps.currentIndex !== 3)
                    privateProps.currentIndex = 3
                column.closeChild()
                pageObject.showAlert(column, qsTr("Pressing ok will delete all browser history.\nContinue?"))
            }
        }
    }

}

