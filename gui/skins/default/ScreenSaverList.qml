import QtQuick 1.1
import BtObjects 1.0
import "logging.js" as Log


MenuElement {
    id: element

    // dimensions
    width: 212
    height: paginator.height

    // object model to retrieve network data
    ObjectModel {
        id: objectModel
        filters: [{objectId: ObjectInterface.IdGuiSettings}]
    }
    // TODO investigate why dataModel is not working as expected
    //dataModel: objectModel.getObject(0)

    // we don't have a ListView, so we don't have a currentIndex property: let's define it
    QtObject {
        id: privateProps
        property int currentIndex: -1
        // HACK dataModel is not working, so let's define a model property here
        // when dataModel work again, change all references!
        property variant model: objectModel.getObject(0)
        property int type: 0
    }

    onChildDestroyed: privateProps.currentIndex = -1

    // retrieves actual configuration information and sets the right component
    Component.onCompleted: {
        screenSaverTypesChanged(privateProps.model.screensaverType)
    }

    // connects child signals to slots
    onChildLoaded: {
        if (child.screenSaverTypesChanged)
            child.screenSaverTypesChanged.connect(screenSaverTypesChanged)
    }

    // slot to manage the change of IP configuration type
    function screenSaverTypesChanged(type) {
        if (type === GuiSettings.None)
            screenSaverLoader.setComponent(noneItem)
        else if (type === GuiSettings.DateTime)
            screenSaverLoader.setComponent(dateTimeItem)
        else if (type === GuiSettings.Text)
            screenSaverLoader.setComponent(textItem)
        else if (type === GuiSettings.Image)
            screenSaverLoader.setComponent(imageItem)
        else
        {
            Log.logWarning("Unrecognized screen saver type " + type)
            return
        }
        typeItem.description = pageObject.names.get('SCREEN_SAVER_TYPE', type)
        privateProps.type = type
    }

    PaginatorColumn {
        id: paginator
        anchors.horizontalCenter: parent.horizontalCenter
        maxHeight: 450

        Image {
            width: 212
            height: 100
            source: "images/common/bg_UnaRegolazione.png"
            Rectangle {
                width: 200
                height: 90
                color: "#88333333"
                anchors.centerIn: parent
                Text {
                    text: qsTr("preview")
                    anchors.centerIn: parent
                }
            }
        }

        // screen saver type menu item (currentIndex === 2)
        MenuItem {
            id: typeItem
            name: qsTr("type")
            description: pageObject.names.get('SCREEN_SAVER_TYPE', privateProps.model.screensaverType)
            hasChild: true
            state: privateProps.currentIndex === 2 ? "selected" : ""
            onClicked: {
                if (privateProps.currentIndex !== 2)
                    privateProps.currentIndex = 2
                element.loadElement("ScreenSaverTypes.qml", name)
            }
        }

        // type item: it is a static list of all possible screen saver types
        AnimatedLoader {
            id: screenSaverLoader
        }
    }

    Component {
        id: noneItem
        Column {
            ControlChoices {
                id: turnOffTime
                description: qsTr("turn off display")
                choice: pageObject.names.get('TURN_OFF_DISPLAY_LIST', currentIndex)
                property int currentIndex: privateProps.model.turnOffTime
                onPlusClicked: if (currentIndex < 8) ++currentIndex
                onMinusClicked: if (currentIndex > 0)--currentIndex
            }
            ButtonOkCancel {
                onOkClicked: {
                    privateProps.model.screensaverType = privateProps.type
                    privateProps.model.turnOffTime = turnOffTime.currentIndex
                }
            }
        }
    }

    Component {
        id: imageItem
        Column {
            Image {
                width: 212
                height: 50
                source: "images/common/btn_menu.png"
                Text {
                    // TODO implementation of browsing/setting of an image
                    text: qsTr("Browse")
                    anchors.fill: parent
                }
                Text {
                    id: screensaverImage
                    text: privateProps.model.screensaverImage
                    anchors.fill: parent
                }
            }
            ControlChoices {
                id: screensaverTimeout
                description: qsTr("screen saver time out")
                choice: pageObject.names.get('SCREEN_SAVER_TIMEOUT', currentIndex)
                property int currentIndex: privateProps.model.timeOut
                onPlusClicked: if (currentIndex < 7) ++currentIndex
                onMinusClicked: if (currentIndex > 0)--currentIndex
            }
            ControlChoices {
                id: turnOffTime
                description: qsTr("turn off display")
                choice: pageObject.names.get('TURN_OFF_DISPLAY_LIST', currentIndex)
                property int currentIndex: privateProps.model.turnOffTime
                onPlusClicked: if (currentIndex < 8) ++currentIndex
                onMinusClicked: if (currentIndex > 0)--currentIndex
            }
            ButtonOkCancel {
                onOkClicked: {
                    privateProps.model.screensaverType = privateProps.type
                    privateProps.model.screensaverImage = screensaverImage.text
                    privateProps.model.timeOut = screensaverTimeout.currentIndex
                    privateProps.model.turnOffTime = turnOffTime.currentIndex
                }
            }
        }
    }

    Component {
        id: textItem
        Column {
            Image {
                width: 212
                height: 50
                source: "images/common/btn_menu.png"
                Text {
                    id: screensaverText
                    text: qsTr("Change text")
                    anchors.fill: parent
                }
            }
            ControlChoices {
                id: screensaverTimeout
                description: qsTr("screen saver time out")
                choice: pageObject.names.get('SCREEN_SAVER_TIMEOUT', currentIndex)
                property int currentIndex: privateProps.model.timeOut
                onPlusClicked: if (currentIndex < 7) ++currentIndex
                onMinusClicked: if (currentIndex > 0)--currentIndex
            }
            ControlChoices {
                id: turnOffTime
                description: qsTr("turn off display")
                choice: pageObject.names.get('TURN_OFF_DISPLAY_LIST', currentIndex)
                property int currentIndex: privateProps.model.turnOffTime
                onPlusClicked: if (currentIndex < 8) ++currentIndex
                onMinusClicked: if (currentIndex > 0)--currentIndex
            }
            ButtonOkCancel {
                onOkClicked: {
                    privateProps.model.screensaverType = privateProps.type
                    privateProps.model.screensaverText = screensaverText.text
                    privateProps.model.timeOut = screensaverTimeout.currentIndex
                    privateProps.model.turnOffTime = turnOffTime.currentIndex
                }
            }
        }
    }

    Component {
        id: dateTimeItem
        Column {
            ControlChoices {
                id: screensaverTimeout
                description: qsTr("screen saver time out")
                choice: pageObject.names.get('SCREEN_SAVER_TIMEOUT', currentIndex)
                property int currentIndex: privateProps.model.timeOut
                onPlusClicked: if (currentIndex < 7) ++currentIndex
                onMinusClicked: if (currentIndex > 0)--currentIndex
            }
            ControlChoices {
                id: turnOffTime
                description: qsTr("turn off display")
                choice: pageObject.names.get('TURN_OFF_DISPLAY_LIST', currentIndex)
                property int currentIndex: privateProps.model.turnOffTime
                onPlusClicked: if (currentIndex < 8) ++currentIndex
                onMinusClicked: if (currentIndex > 0)--currentIndex
            }
            ButtonOkCancel {
                onOkClicked: {
                    privateProps.model.screensaverType = privateProps.type
                    privateProps.model.timeOut = screensaverTimeout.currentIndex
                    privateProps.model.turnOffTime = turnOffTime.currentIndex
                }
            }
        }
    }
}
