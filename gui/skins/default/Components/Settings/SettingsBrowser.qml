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
                pageObject.installPopup(popupEditUrl)
            }
            Component {
                id: popupEditUrl
                FavoriteEditPopup {
                    title: qsTr("Insert new home page")
                    topInputLabel: qsTr("New URL:")
                    topInputText: global.homePageUrl
                    bottomVisible: false

                    function okClicked() {
                        global.homePageUrl = topInputText
                    }
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
                pageObject.installPopup(alertComponent, {"message": qsTr("Pressing ok will delete all browser history.\nContinue?"), "source": column})
            }
        }

        Component {
            id: alertComponent
            Alert {}
        }
    }

}

