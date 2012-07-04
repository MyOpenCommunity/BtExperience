import QtQuick 1.1
import BtObjects 1.0
import BtExperience 1.0
import Components 1.0
import Components.Text 1.0
import "../../js/logging.js" as Log


MenuColumn {
    id: column

    // dimensions
    width: 212
    height: preview.height + typeItem.height + screenSaverLoader.height
    property string imagesPath: "../../images/"

    Component {
        id: screenSaverTypes
        ScreenSaverTypes {}
    }

    function okClicked() {
        closeColumn()
    }

    // we don't have a ListView, so we don't have a currentIndex property: let's define it
    QtObject {
        id: privateProps
        property int currentIndex: -1
        property int type: 0
    }

    onChildDestroyed: privateProps.currentIndex = -1

    // retrieves actual configuration information and sets the right component
    Component.onCompleted: {
        screenSaverTypesChanged(global.guiSettings.screensaverType)
    }

    // connects child signals to slots
    onChildLoaded: {
        if (child.screenSaverTypesChanged)
            child.screenSaverTypesChanged.connect(screenSaverTypesChanged)
    }

    Component {
        id: bouncingLogo
        ScreenSaverBouncingImage {}
    }

    Component {
        id: flashyRectangles
        ScreenSaverRectangles {}
    }

    // slot to manage the change of IP configuration type
    function screenSaverTypesChanged(type) {
        var screensaver = bouncingLogo
        if (type === GuiSettings.None)
            screenSaverLoader.setComponent(noneItem)
        else if (type === GuiSettings.DateTime)
            screenSaverLoader.setComponent(dateTimeItem)
        else if (type === GuiSettings.Text)
            screenSaverLoader.setComponent(textItem)
        else if (type === GuiSettings.Image)
            screenSaverLoader.setComponent(imageItem)
        else if (type === GuiSettings.Rectangles)
        {
            screensaver = flashyRectangles
            screenSaverLoader.setComponent(rectanglesItem)
        }
        else
        {
            Log.logWarning("Unrecognized screen saver type " + type)
            return
        }
        preview.setPreview(screensaver)
        typeItem.description = pageObject.names.get('SCREEN_SAVER_TYPE', type)
        privateProps.type = type
    }

    PaginatorColumn {
        id: paginator
        anchors.horizontalCenter: parent.horizontalCenter
        maxHeight: 450

        Image {
            id: preview
            width: 212
            height: 100
            source: imagesPath + "scenari.jpg"
            ScreenSaver {
                id: screensaverPreview
                width: parent.width
                height: parent.height
                timeoutActive: false
            }
            Rectangle {
                anchors.fill: parent
                color: "#88333333"
                anchors.centerIn: parent
                UbuntuLightText {
                    text: qsTr("preview")
                    anchors.centerIn: parent
                }
            }

            function setPreview(screensaver) {
                screensaverPreview.screensaverComponent = screensaver
            }
        }

        // screen saver type menu item (currentIndex === 2)
        MenuItem {
            id: typeItem
            name: qsTr("type")
            description: pageObject.names.get('SCREEN_SAVER_TYPE', global.guiSettings.screensaverType)
            hasChild: true
            state: privateProps.currentIndex === 2 ? "selected" : ""
            onClicked: {
                if (privateProps.currentIndex !== 2)
                    privateProps.currentIndex = 2
                column.loadColumn(screenSaverTypes, name)
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
                property int currentIndex: global.guiSettings.turnOffTime
                onPlusClicked: if (currentIndex < 8) ++currentIndex
                onMinusClicked: if (currentIndex > 0)--currentIndex
            }
            ButtonOkCancel {
                onOkClicked: {
                    global.guiSettings.screensaverType = privateProps.type
                    global.guiSettings.turnOffTime = turnOffTime.currentIndex
                    column.okClicked()
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
                source: imagesPath + "common/menu_column_item_bg.svg"
                UbuntuLightText {
                    // TODO implementation of browsing/setting of an image
                    text: qsTr("Browse")
                    anchors.fill: parent
                }
                UbuntuLightText {
                    id: screensaverImage
                    text: global.guiSettings.screensaverImage
                    anchors.fill: parent
                }
            }
            ControlChoices {
                id: screensaverTimeout
                description: qsTr("screen saver time out")
                choice: pageObject.names.get('SCREEN_SAVER_TIMEOUT', currentIndex)
                property int currentIndex: global.guiSettings.timeOut
                onPlusClicked: if (currentIndex < 7) ++currentIndex
                onMinusClicked: if (currentIndex > 0)--currentIndex
            }
            ControlChoices {
                id: turnOffTime
                description: qsTr("turn off display")
                choice: pageObject.names.get('TURN_OFF_DISPLAY_LIST', currentIndex)
                property int currentIndex: global.guiSettings.turnOffTime
                onPlusClicked: if (currentIndex < 8) ++currentIndex
                onMinusClicked: if (currentIndex > 0)--currentIndex
            }
            ButtonOkCancel {
                onOkClicked: {
                    global.guiSettings.screensaverType = privateProps.type
                    global.guiSettings.screensaverImage = screensaverImage.text
                    global.guiSettings.timeOut = screensaverTimeout.currentIndex
                    global.guiSettings.turnOffTime = turnOffTime.currentIndex
                    column.okClicked()

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
                source: imagesPath + "common/menu_column_item_bg.svg"
                UbuntuLightText {
                    id: screensaverText
                    text: qsTr("Change text")
                    anchors.fill: parent
                }
            }
            ControlChoices {
                id: screensaverTimeout
                description: qsTr("screen saver time out")
                choice: pageObject.names.get('SCREEN_SAVER_TIMEOUT', currentIndex)
                property int currentIndex: global.guiSettings.timeOut
                onPlusClicked: if (currentIndex < 7) ++currentIndex
                onMinusClicked: if (currentIndex > 0)--currentIndex
            }
            ControlChoices {
                id: turnOffTime
                description: qsTr("turn off display")
                choice: pageObject.names.get('TURN_OFF_DISPLAY_LIST', currentIndex)
                property int currentIndex: global.guiSettings.turnOffTime
                onPlusClicked: if (currentIndex < 8) ++currentIndex
                onMinusClicked: if (currentIndex > 0)--currentIndex
            }
            ButtonOkCancel {
                onOkClicked: {
                    global.guiSettings.screensaverType = privateProps.type
                    global.guiSettings.screensaverText = screensaverText.text
                    global.guiSettings.timeOut = screensaverTimeout.currentIndex
                    global.guiSettings.turnOffTime = turnOffTime.currentIndex
                    column.okClicked()
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
                property int currentIndex: global.guiSettings.timeOut
                onPlusClicked: if (currentIndex < 7) ++currentIndex
                onMinusClicked: if (currentIndex > 0)--currentIndex
            }
            ControlChoices {
                id: turnOffTime
                description: qsTr("turn off display")
                choice: pageObject.names.get('TURN_OFF_DISPLAY_LIST', currentIndex)
                property int currentIndex: global.guiSettings.turnOffTime
                onPlusClicked: if (currentIndex < 8) ++currentIndex
                onMinusClicked: if (currentIndex > 0)--currentIndex
            }
            ButtonOkCancel {
                onOkClicked: {
                    global.guiSettings.screensaverType = privateProps.type
                    global.guiSettings.timeOut = screensaverTimeout.currentIndex
                    global.guiSettings.turnOffTime = turnOffTime.currentIndex
                    column.okClicked()
                }
            }
        }
    }

    Component {
        id: rectanglesItem
        Column {
            ControlChoices {
                id: screensaverTimeout
                description: qsTr("screen saver time out")
                choice: pageObject.names.get('SCREEN_SAVER_TIMEOUT', currentIndex)
                property int currentIndex: global.guiSettings.timeOut
                onPlusClicked: if (currentIndex < 7) ++currentIndex
                onMinusClicked: if (currentIndex > 0)--currentIndex
            }
            ControlChoices {
                id: turnOffTime
                description: qsTr("turn off display")
                choice: pageObject.names.get('TURN_OFF_DISPLAY_LIST', currentIndex)
                property int currentIndex: global.guiSettings.turnOffTime
                onPlusClicked: if (currentIndex < 8) ++currentIndex
                onMinusClicked: if (currentIndex > 0)--currentIndex
            }
            ButtonOkCancel {
                onOkClicked: {
                    global.guiSettings.screensaverType = privateProps.type
                    global.guiSettings.timeOut = screensaverTimeout.currentIndex
                    global.guiSettings.turnOffTime = turnOffTime.currentIndex
                    column.okClicked()
                }
            }
        }
    }
}
