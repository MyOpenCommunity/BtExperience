import QtQuick 1.1
import BtObjects 1.0
import "../../js/logging.js" as Log
import Components 1.0


MenuColumn {
    id: column

    Component {
        id: networkState
        NetworkState {}
    }

    Component {
        id: ipConfigurations
        IPConfigurations {}
    }

    // object model to retrieve network data
    ObjectModel {
        id: objectModel
        filters: [{objectId: ObjectInterface.IdPlatformSettings}]
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
    Component.onCompleted: {
        if (privateProps.model.lanConfig === PlatformSettings.Static)
            configurationLoader.setComponent(optionsItem);
        else
            configurationLoader.setComponent(summaryItem);
    }

    // connects child signals to slots
    onChildLoaded: {
        if (child.ipConfigurationChanged)
            child.ipConfigurationChanged.connect(ipConfigurationChanged)
        if (child.networkChanged)
            child.networkChanged.connect(networkChanged)
    }

    // slot to manage the change of IP configuration type
    function ipConfigurationChanged(configuration) {
        if (configuration === PlatformSettings.Dhcp)
            configurationLoader.setComponent(summaryItem)
        else if (configuration === PlatformSettings.Static)
            configurationLoader.setComponent(optionsItem)
        else
            Log.logWarning("Unrecognized IP configuration" + configuration)
    }

    // slot to manage enable/disable of the network adapter
    function networkChanged(state) {
        privateProps.model.lanStatus = state;
    }

    PaginatorColumn {
        id: paginator
        anchors.horizontalCenter: parent.horizontalCenter
        maxHeight: 350

        // network state menu item (currentIndex === 1)
        MenuItem {
            id: networkStateItem
            name: qsTr("network state")
            description: privateProps.model.connectionStatus === PlatformSettings.Down ? qsTr("disconnected") : qsTr("connected")
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
            description: privateProps.model.lanConfig === PlatformSettings.Dhcp   ? qsTr("DHCP") :
                         privateProps.model.lanConfig === PlatformSettings.Static ? qsTr("disconnected") :
                                                                                    qsTr("unknown")
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
        }
    }

    // TODO: use the right background
    Component {
        id: summaryItem
        Item {
            width: 212
            height: 50 * 5
            Column {
                ControlTitleValue {
                    title: qsTr("MAC address")
                    value: privateProps.model.mac
                }
                ControlTitleValue {
                    title: qsTr("IP address")
                    value: privateProps.model.address
                }
                ControlTitleValue {
                    title: qsTr("Subnet mask")
                    value: privateProps.model.subnet
                }
                ControlTitleValue {
                    title: qsTr("Gateway")
                    value: privateProps.model.gateway
                }
                ControlTitleValue {
                    title: qsTr("DNS")
                    value: privateProps.model.dns
                }
            }
        }
    }

    // TODO: use the right background; add the keyboard
    Component {
        id: optionsItem

        // we have some input elements, so a FocusScope is needed to make everything work
        FocusScope {
            id: optionsFocusScope
            // FocusScope needs to bind to visual properties of the children (I'm not sure is needed)
            x: background.x
            y: background.y
            width: background.width
            height: background.height
            Item {
                id: background
                width: 212
                height: 50 * 5
                Column {
                    ControlTitleValue {
                        title: qsTr("MAC address")
                        value: privateProps.model.mac
                    }
                    ControlTitleValue {
                        title: qsTr("IP address")
                        value: privateProps.model.address
                        readOnly: false
                        onAccepted: privateProps.model.address = value
                    }
                    ControlTitleValue {
                        title: qsTr("Subnet mask")
                        value: privateProps.model.subnet
                        readOnly: false
                        onAccepted: privateProps.model.subnet = value
                    }
                    ControlTitleValue {
                        title: qsTr("Gateway")
                        value: privateProps.model.gateway
                        readOnly: false
                        onAccepted: privateProps.model.gateway = value
                    }
                    ControlTitleValue {
                        title: qsTr("DNS")
                        value: privateProps.model.dns
                        readOnly: false
                        onAccepted: privateProps.model.dns = value
                    }
                }
            }
        }
    }
}
