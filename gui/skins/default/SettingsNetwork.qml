import QtQuick 1.1
import BtObjects 1.0
import "logging.js" as Log


MenuElement {
    id: element

    // dimensions
    width: 212
    height: networkStateItem.height + ipConfigurationItem.height + configurationLoader.height

    // object model to retrieve network data
    ObjectModel {
        id: objectModel
        filters: [{objectId: ObjectInterface.IdNetwork}]
    }
    // TODO investigate why dataModel is not working as expected
    //dataModel: objectModel.getObject(0)

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
    }

    onChildDestroyed: privateProps.currentIndex = -1

    // network state menu item (currentIndex === 1)
    MenuItem {
        id: networkStateItem
        name: qsTr("network state")
        description: qsTr("connected")
        hasChild: true
        state: privateProps.currentIndex === 1 ? "selected" : ""
        status: privateProps.model.lanStatus ? 1 : 0
        onClicked: {
            if (privateProps.currentIndex !== 1)
                privateProps.currentIndex = 1
            element.loadElement("NetworkState.qml", name)
        }
    }

    // ip configuration menu item (currentIndex === 2)
    MenuItem {
        id: ipConfigurationItem
        anchors.top: networkStateItem.bottom
        name: qsTr("IP configuration")
        description: qsTr("DHCP")
        hasChild: true
        state: privateProps.currentIndex === 2 ? "selected" : ""
        onClicked: {
            if (privateProps.currentIndex !== 2)
                privateProps.currentIndex = 2
            element.loadElement("IPConfigurations.qml", name)
        }
    }

    // configuration item: it may be a static list of textual informations
    // (DHCP case) or a list of controls to change network configuration
    // (static IP case)
    AnimatedLoader {
        id: configurationLoader
        anchors.bottom: parent.bottom
    }

    // retrieves actual configuration information and sets the right component
    Component.onCompleted: {
        // TODO: load item wrt IP configuration type
        configurationLoader.setComponent(summaryItem)
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
        if (configuration === Network.Dhcp)
            configurationLoader.setComponent(summaryItem)
        else if (configuration === Network.Static)
            configurationLoader.setComponent(optionsItem)
        else
            Log.logWarning("Unrecognized IP configuration" + configuration)
    }

    // slot to manage enable/disable of the network adapter
    function networkChanged(state) {
        privateProps.model.LanStatus = state;
    }



    // TODO: use the right background
    Component {
        id: summaryItem
        Column {
            Image {
                width: 212
                height: 50 * 5
                source: "images/common/bg_zone.png"
                anchors.bottom: parent.bottom

                Text {
                    id: macAddressTitle
                    text: qsTr("MAC address")
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 5
                }
                Text {
                    id: macAddressValue
                    text: privateProps.model.mac
                    font.pixelSize: 16
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: macAddressTitle.bottom
                    anchors.topMargin: 5
                    anchors.bottomMargin: 5
                }

                Text {
                    id: ipAddressTitle
                    text: qsTr("IP address")
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: macAddressValue.bottom
                    anchors.topMargin: 5
                }
                Text {
                    id: ipAddressValue
                    text: privateProps.model.address
                    font.pixelSize: 16
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: ipAddressTitle.bottom
                    anchors.topMargin: 5
                }

                Text {
                    id: subnetMaskTitle
                    text: qsTr("Subnet mask")
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: ipAddressValue.bottom
                    anchors.topMargin: 5
                }
                Text {
                    id: subnetMaskValue
                    text: privateProps.model.subnet
                    font.pixelSize: 16
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: subnetMaskTitle.bottom
                    anchors.topMargin: 5
                }

                Text {
                    id: gatewayTitle
                    text: qsTr("Gateway")
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: subnetMaskValue.bottom
                    anchors.topMargin: 5
                }
                Text {
                    id: gatewayValue
                    text: privateProps.model.gateway
                    font.pixelSize: 16
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: gatewayTitle.bottom
                    anchors.topMargin: 5
                }

                Text {
                    id: dnsTitle
                    text: qsTr("DNS")
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: gatewayValue.bottom
                    anchors.topMargin: 5
                }
                Text {
                    id: dnsValue
                    text: privateProps.model.dns
                    font.pixelSize: 16
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: dnsTitle.bottom
                    anchors.topMargin: 5
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

            Column {
                Image {
                    id: background
                    width: 212
                    height: 50 * 5
                    source: "images/common/bg_zone.png"
                    anchors.bottom: parent.bottom

                    Text {
                        id: macAddressTitle
                        text: qsTr("MAC address")
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: 5
                    }
                    Text {
                        id: macAddressValue
                        text: privateProps.model.mac
                        font.pixelSize: 16
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: macAddressTitle.bottom
                        anchors.topMargin: 5
                        anchors.bottomMargin: 5
                    }

                    Text {
                        id: ipAddressTitle
                        text: qsTr("IP address")
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: macAddressValue.bottom
                        anchors.topMargin: 5
                    }
                    TextInput {
                        id: ipAddressValue
                        text: privateProps.model.address
                        font.pixelSize: 16
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: ipAddressTitle.bottom
                        anchors.topMargin: 5
                        onAccepted: privateProps.model.address = text
                    }

                    Text {
                        id: subnetMaskTitle
                        text: qsTr("Subnet mask")
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: ipAddressValue.bottom
                        anchors.topMargin: 5
                    }
                    TextInput {
                        id: subnetMaskValue
                        text: privateProps.model.subnet
                        font.pixelSize: 16
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: subnetMaskTitle.bottom
                        anchors.topMargin: 5
                        onAccepted: privateProps.model.subnet = text
                    }

                    Text {
                        id: gatewayTitle
                        text: qsTr("Gateway")
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: subnetMaskValue.bottom
                        anchors.topMargin: 5
                    }
                    TextInput {
                        id: gatewayValue
                        text: privateProps.model.gateway
                        font.pixelSize: 16
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: gatewayTitle.bottom
                        anchors.topMargin: 5
                        onAccepted: privateProps.model.gateway = text
                    }

                    Text {
                        id: dnsTitle
                        text: qsTr("DNS")
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: gatewayValue.bottom
                        anchors.topMargin: 5
                    }
                    TextInput {
                        id: dnsValue
                        text: privateProps.model.dns
                        font.pixelSize: 16
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: dnsTitle.bottom
                        anchors.topMargin: 5
                        onAccepted: privateProps.model.dns = text
                    }

                }
            }
        }
    }
}
