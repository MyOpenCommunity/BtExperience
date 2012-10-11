import QtQuick 1.1
import Components 1.0


MenuColumn {
    id: column

    // redefined to implement menu navigation
    function openMenu(navigationTarget) {
        if (navigationTarget === "HandsFree") {
            if (privateProps.currentIndex !== 1)
                privateProps.currentIndex = 1
            column.loadColumn(handsFreeComponent, handsFreeMenuItem.name)
            return 0
        }
        if (navigationTarget === "AutoOpen") {
            if (privateProps.currentIndex !== 2)
                privateProps.currentIndex = 2
            column.loadColumn(autoOpenComponent, autoOpenMenuItem.name)
            return 0
        }
        if (navigationTarget === "VdeMute") {
            if (privateProps.currentIndex !== 3)
                privateProps.currentIndex = 3
            column.loadColumn(vdeMuteComponent, vdeMuteMenuItem.name)
            return 0
        }
        return -2 // wrong target
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
            id: handsFreeMenuItem
            name: qsTr("hands free")
            hasChild: true
            isSelected: privateProps.currentIndex === 1
            onClicked: {
                if (privateProps.currentIndex !== 1)
                    privateProps.currentIndex = 1

                column.loadColumn(handsFreeComponent, name)
            }

            Component {
                id: handsFreeComponent
                SettingsHandsFree {
                }
            }
        }

        MenuItem {
            id: autoOpenMenuItem
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
            id: vdeMuteMenuItem
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

