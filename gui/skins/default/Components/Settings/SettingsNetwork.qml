import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Text 1.0
import "../../js/logging.js" as Log
import "../../js/Stack.js" as Stack
import "../../js/EventManager.js" as EventManager


/**
  * A menu to manage network parameters.
  */
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
            onTouched: {
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
            onTouched: {
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
        id: alertComponent
        Alert {
            onAlertCancelClicked: {
                privateProps.model.reset()
                column.closeColumn()
            }
            onAlertOkClicked: {
                privateProps.model.apply()
                EventManager.eventManager.notificationsEnabled = false
                Stack.backToHome({state: "pageLoading"})
            }
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
                    pageObject.installPopup(alertComponent, {"message": pageObject.names.get('REBOOT', 0)})
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
                    id: value1

                    function saveValue(newValue) {
                        privateProps.model.address = newValue
                    }

                    title: qsTr("IP address")
                    value: privateProps.model.address
                    onModifyIp: {
                        if (value !== "")
                            pageObject.installPopup(editIpAddress, {originalAddress: value, object: value1})
                    }
                }
                ControlTitleValue {
                    id: value2

                    function saveValue(newValue) {
                        privateProps.model.subnet = newValue
                    }

                    title: qsTr("Subnet mask")
                    value: privateProps.model.subnet
                    onModifyIp: {
                        if (value !== "")
                            pageObject.installPopup(editIpAddress, {originalAddress: value, object: value2})
                    }
                }
                ControlTitleValue {
                    id: value3

                    function saveValue(newValue) {
                        privateProps.model.gateway = newValue
                    }

                    title: qsTr("Gateway")
                    value: privateProps.model.gateway
                    onModifyIp: {
                        if (value !== "")
                            pageObject.installPopup(editIpAddress, {originalAddress: value, object: value3})
                    }
                }
                ControlTitleValue {
                    id: value4

                    function saveValue(newValue) {
                        privateProps.model.dns1 = newValue
                    }

                    title: qsTr("Primary DNS")
                    value: privateProps.model.dns1
                    onModifyIp: {
                        if (value !== "")
                            pageObject.installPopup(editIpAddress, {originalAddress: value, object: value4})
                    }
                }
                ControlTitleValue {
                    id: value5

                    function saveValue(newValue) {
                        privateProps.model.dns2 = newValue
                    }

                    title: qsTr("Secondary DNS")
                    value: privateProps.model.dns2
                    onModifyIp: {
                        if (value !== "")
                            pageObject.installPopup(editIpAddress, {originalAddress: value, object: value5})
                    }
                }
                ButtonOkCancel {
                    onOkClicked: {
                        focus = true // to accept current value (if any)
                        pageObject.installPopup(alertComponent, {"message": pageObject.names.get('REBOOT', 0)})
                    }
                    onCancelClicked: {
                        privateProps.model.reset()
                        column.closeColumn()
                    }
                }
            }
        }
    }

    Component {
        id: editIpAddress
        Column {
            id: editPopup
            property string originalAddress
            property variant object

            signal closePopup

            spacing: 2

            SvgImage {
                id: editBg
                source: "../../images/scenarios/bg_testo.svg"
                height: 80

                Row {
                    spacing: 5
                    anchors.centerIn: parent

                    IpFieldInput {
                        id: field1
                        anchors {
                            top: parent.top
                            topMargin: parent.height / 100 * 10
                        }
                        width: editBg.width/ 6
                        text: editPopup.originalAddress.split('.')[0]
                        containerWidget: editPopup

                        onSkipField: field2.focus = true
                    }

                    UbuntuMediumText {
                        font.pixelSize: 20
                        text: "."
                        anchors.bottom: parent.bottom
                    }

                    IpFieldInput {
                        id: field2
                        anchors {
                            top: parent.top
                            topMargin: parent.height / 100 * 10
                        }
                        width: editBg.width/ 6
                        text: editPopup.originalAddress.split('.')[1]
                        containerWidget: editPopup

                        onSkipField: field3.focus = true
                    }

                    UbuntuMediumText {
                        font.pixelSize: 20
                        text: "."
                        anchors.bottom: parent.bottom
                    }

                    IpFieldInput {
                        id: field3
                        anchors {
                            top: parent.top
                            topMargin: parent.height / 100 * 10
                        }
                        width: editBg.width/ 6
                        text: editPopup.originalAddress.split('.')[2]
                        containerWidget: editPopup

                        onSkipField: field4.focus = true
                    }

                    UbuntuMediumText {
                        font.pixelSize: 20
                        text: "."
                        anchors.bottom: parent.bottom
                    }

                    IpFieldInput {
                        id: field4
                        anchors {
                            top: parent.top
                            topMargin: parent.height / 100 * 10
                        }
                        width: editBg.width/ 6
                        text: editPopup.originalAddress.split('.')[3]
                        containerWidget: editPopup

                        onSkipField: field1.focus = true
                    }
                }
            }

            SvgImage {
                source: "../../images/scenarios/bg_ok_annulla.svg"

                Row {
                    anchors {
                        right: parent.right
                        rightMargin: parent.width / 100 * 2
                        verticalCenter: parent.verticalCenter
                    }

                    ButtonThreeStates {
                        defaultImage: "../../images/common/btn_99x35.svg"
                        pressedImage: "../../images/common/btn_99x35_P.svg"
                        selectedImage: "../../images/common/btn_99x35_S.svg"
                        shadowImage: "../../images/common/btn_shadow_99x35.svg"
                        text: qsTr("ok")
                        font.pixelSize: 14
                        enabled: field1.validInput && field2.validInput &&
                                 field3.validInput && field4.validInput
                        onTouched: {
                            editPopup.object.saveValue(field1.text + "." + field2.text +
                                                       "." + field3.text + "." + field4.text)
                            editPopup.closePopup()
                        }
                    }

                    ButtonThreeStates {
                        defaultImage: "../../images/common/btn_99x35.svg"
                        pressedImage: "../../images/common/btn_99x35_P.svg"
                        selectedImage: "../../images/common/btn_99x35_S.svg"
                        shadowImage: "../../images/common/btn_shadow_99x35.svg"
                        text: qsTr("cancel")
                        font.pixelSize: 14
                        onTouched: editPopup.closePopup()
                    }
                }
            }
        }
    }
}
