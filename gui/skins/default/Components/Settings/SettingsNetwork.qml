import QtQuick 1.1
import BtObjects 1.0
import "../../js/logging.js" as Log
import "../../js/Stack.js" as Stack
import Components 1.0


MenuColumn {
    id: column

    Component {
        id: networkState
        NetworkState {
            platform: privateProps.model
        }
    }

    Component {
        id: ipConfigurations
        IPConfigurations {
            platform: privateProps.model
        }
    }

    // object model to retrieve network data
    ObjectModel {
        id: objectModel
        filters: [{objectId: ObjectInterface.IdPlatformSettings}]
    }

    function alertCancelClicked() {
        privateProps.model.reset()
        column.closeColumn()
    }

    function alertOkClicked() {
        privateProps.model.apply()
        Stack.backToHome({state: "pageLoading"})
    }

    // we don't have a ListView, so we don't have a currentIndex property: let's define it
    QtObject {
        id: privateProps
        property int currentIndex: -1
        // -1 -> no selection
        //  1 -> network state menu
        //  2 -> ip configuration menu
        //  3 -> mac address
        //  4 -> ip address
        //  5 -> subnet mask
        //  6 -> gateway
        //  7 -> dns
        // HACK dataModel is not working, so let's define a model property here
        // when dataModel work again, change all references!
        property variant model: objectModel.getObject(0)

        Component.onCompleted: model.requestNetworkSettings()
    }

    onChildDestroyed: privateProps.currentIndex = -1

    // retrieves actual configuration information and sets the right component
    function loadMenu() {
        if (privateProps.model.lanConfig === PlatformSettings.Static)
            configurationLoader.setComponent(optionsItem);
        else
            configurationLoader.setComponent(summaryItem);
    }

    Component.onCompleted: loadMenu()

    Connections {
        target: privateProps.model
        onLanConfigChanged: loadMenu()
    }

    Column {
        id: paginator

        // network state menu item (currentIndex === 1)
        MenuItem {
            id: networkStateItem
            name: qsTr("network state")
            description: privateProps.model.connectionStatus === PlatformSettings.Down ? qsTr("Disconnected") : qsTr("Connected")
            hasChild: true
            isSelected: privateProps.currentIndex === 1
            status: privateProps.model.lanStatus ? 1 : 0
            onClicked: {
                if (privateProps.currentIndex !== 1)
                    privateProps.currentIndex = 1
                column.loadColumn(networkState, name)
            }
        }

        // ip configuration menu item (currentIndex === 2)
        MenuItem {
            id: ipConfigurationItem
            name: qsTr("IP configuration")
            description: privateProps.model.lanConfig === PlatformSettings.Dhcp   ? qsTr("DHCP") : qsTr("Static")
            hasChild: true
            isSelected: privateProps.currentIndex === 2
            onClicked: {
                if (privateProps.currentIndex !== 2)
                    privateProps.currentIndex = 2
                column.loadColumn(ipConfigurations, name)
            }
        }
        // configuration item: it may be a static list of textual informations
        // (DHCP case) or a list of controls to change network configuration
        // (static IP case)
        AnimatedLoader {
            id: configurationLoader
            width: networkStateItem.width
        }
    }

    Component {
        id: summaryItem
        Column {
            ControlTitleValue {
                title: qsTr("MAC address")
                value: privateProps.model.mac || qsTr("Unknown")
            }
            ControlTitleValue {
                title: qsTr("IP address")
                value: privateProps.model.address || qsTr("Unknown")
            }
            ControlTitleValue {
                title: qsTr("Subnet mask")
                value: privateProps.model.subnet || qsTr("Unknown")
            }
            ControlTitleValue {
                title: qsTr("Gateway")
                value: privateProps.model.gateway || qsTr("Unknown")
            }
            ControlTitleValue {
                title: qsTr("Primary DNS")
                value: privateProps.model.dns1 || qsTr("Unknown")
            }
            ControlTitleValue {
                title: qsTr("Secondary DNS")
                value: privateProps.model.dns2 || qsTr("Unknown")
            }
            ButtonOkCancel {
                onOkClicked: {
                    pageObject.showAlert(column, pageObject.names.get('REBOOT', 0))
                }
                onCancelClicked: {
                    privateProps.model.reset()
                    column.closeColumn()
                }
            }
        }
    }

    Component {
        id: optionsItem

        // we have some input elements, so a FocusScope is needed to make everything work
        FocusScope {
            width: childrenRect.width
            height: childrenRect.height
            // FocusScope needs to bind to visual properties of the children (I'm not sure is needed)
            Column {
                ControlTitleValue {
                    title: qsTr("MAC address")
                    value: privateProps.model.mac || qsTr("Unknown")
                }
                ControlTitleValue {
                    title: qsTr("IP address")
                    value: privateProps.model.address
                    readOnly: false
                    inputMask: '000.000.000.000'
                    onAccepted: privateProps.model.address = value
                }
                ControlTitleValue {
                    title: qsTr("Subnet mask")
                    value: privateProps.model.subnet
                    readOnly: false
                    inputMask: '000.000.000.000'
                    onAccepted: privateProps.model.subnet = value
                }
                ControlTitleValue {
                    title: qsTr("Gateway")
                    value: privateProps.model.gateway
                    readOnly: false
                    inputMask: '000.000.000.000'
                    onAccepted: privateProps.model.gateway = value
                }
                ControlTitleValue {
                    title: qsTr("Primary DNS")
                    value: privateProps.model.dns1
                    readOnly: false
                    inputMask: '000.000.000.000'
                    onAccepted: privateProps.model.dns1 = value
                }
                ControlTitleValue {
                    title: qsTr("Secondary DNS")
                    value: privateProps.model.dns2
                    readOnly: false
                    inputMask: '000.000.000.000'
                    onAccepted: privateProps.model.dns2 = value
                }
                ButtonOkCancel {
                    onOkClicked: {
                        focus = true // to accept current value (if any)
                        pageObject.showAlert(column, pageObject.names.get('REBOOT', 0))
                    }
                    onCancelClicked: {
                        privateProps.model.reset()
                        column.closeColumn()
                    }
                }
            }
        }
    }
}
