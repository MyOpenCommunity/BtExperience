import QtQuick 1.1
import Components 1.0


MenuColumn {
    id: column

    // redefined to implement menu navigation
    function openMenu(navigationTarget) {
        if (navigationTarget === "AutoAnswer") {
            // last menu to open, resets navigationTarget
            column.pageObject.navigationTarget = 0
            column.loadColumn(autoAnswerComponent, autoAnswerMenuItem.name)
            return true
        }
        return false
    }

    QtObject {
        id: privateProps
        property int currentIndex: -1
    }

    onChildDestroyed: {
        privateProps.currentIndex = -1
    }

    Column {
        MenuItem {
            id: autoAnswerMenuItem
            name: qsTr("auto answer")
            hasChild: true
            isSelected: privateProps.currentIndex === 1
            onClicked: {
                if (privateProps.currentIndex !== 1)
                    privateProps.currentIndex = 1

                column.loadColumn(autoAnswerComponent, name)
            }

            Component {
                id: autoAnswerComponent
                SettingsAutoAnswer {
                }
            }
        }

        MenuItem {
            name: qsTr("auto open")
            hasChild: true
            isSelected: privateProps.currentIndex === 2
            onClicked: {
                if (privateProps.currentIndex !== 2)
                    privateProps.currentIndex = 2

                column.loadColumn(autoOpenComponent, name)
            }

            Component {
                id: autoOpenComponent
                SettingsAutoOpen {
                }
            }
        }

        MenuItem {
            name: qsTr("vde mute")
            hasChild: true
            isSelected: privateProps.currentIndex === 3
            onClicked: {
                if (privateProps.currentIndex !== 3)
                    privateProps.currentIndex = 3
                column.loadColumn(vdeMuteComponent, name)
            }

            Component {
                id: vdeMuteComponent
                SettingsVdeMute {
                }
            }
        }
    }

}

