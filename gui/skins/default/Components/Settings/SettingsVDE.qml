import QtQuick 1.1
import Components 1.0
import "../../js/navigationconstants.js" as NavigationConstants


MenuColumn {
    id: column

    // needed for menu navigation
    function targetsKnown() {
        return {
            "HandsFree": privateProps.openHandsFreeMenu,
            "AutoOpen": privateProps.openAutoOpenMenu,
            "VdeMute": privateProps.openVdeMuteMenu,
            "VdeTeleloop": privateProps.openTeleloopMenu,
        }
    }

    QtObject {
        id: privateProps

        property int currentIndex: -1

        function openHandsFreeMenu(navigationData) {
            if (privateProps.currentIndex !== 1)
                privateProps.currentIndex = 1
            column.loadColumn(handsFreeComponent, handsFreeMenuItem.name)
            return NavigationConstants.NAVIGATION_FINISHED_OK
        }

        function openAutoOpenMenu(navigationData) {
            if (privateProps.currentIndex !== 2)
                privateProps.currentIndex = 2
            column.loadColumn(autoOpenComponent, autoOpenMenuItem.name)
            return NavigationConstants.NAVIGATION_FINISHED_OK
        }

        function openVdeMuteMenu(navigationData) {
            if (privateProps.currentIndex !== 3)
                privateProps.currentIndex = 3
            column.loadColumn(vdeMuteComponent, vdeMuteMenuItem.name)
            return NavigationConstants.NAVIGATION_FINISHED_OK
        }

        function openTeleloopMenu(navigationData) {
            if (privateProps.currentIndex !== 4)
                privateProps.currentIndex = 4
            column.loadColumn(teleloopComponent, teleloopMenuItem.name)
            return NavigationConstants.NAVIGATION_FINISHED_OK
        }
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
            name: qsTr("Ringtone exclusion")
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

        MenuItem {
            id: teleloopMenuItem
            name: qsTr("Teleloop")
            hasChild: true
            isSelected: privateProps.currentIndex === 4
            onClicked: {
                if (privateProps.currentIndex !== 4)
                    privateProps.currentIndex = 4
                column.loadColumn(teleloopComponent, name)
            }

            Component {
                id: teleloopComponent
                SettingsTeleloop {
                }
            }
        }
    }

}

