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
        filters: [{objectId: ObjectInterface.IdPlatform}]
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
    }

    onChildDestroyed: privateProps.currentIndex = -1

    // retrieves actual configuration information and sets the right component
    Component.onCompleted: {
        screenSaverLoader.setComponent(noneItem);
    }

    // connects child signals to slots
    onChildLoaded: {
        if (child.screenSaverTypesChanged)
            child.screenSaverTypesChanged.connect(screenSaverTypesChanged)
    }

    // slot to manage the change of IP configuration type
    function screenSaverTypesChanged(type) {
        typeItem.description = type;
        if (type === pageObject.names.get('SCREEN_SAVER_TYPE', 0))
            screenSaverLoader.setComponent(noneItem)
        else if (type === pageObject.names.get('SCREEN_SAVER_TYPE', 1))
            screenSaverLoader.setComponent(imageItem)
        else if (type === pageObject.names.get('SCREEN_SAVER_TYPE', 2))
            screenSaverLoader.setComponent(textItem)
        else if (type === pageObject.names.get('SCREEN_SAVER_TYPE', 3))
            screenSaverLoader.setComponent(dateTimeItem)
        else
            Log.logWarning("Unrecognized screen saver type" + type)
    }

    PaginatorColumn {
        id: paginator
        anchors.horizontalCenter: parent.horizontalCenter
        maxHeight: 250

        Column {
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
                description: qsTr("none")
                hasChild: true
                state: privateProps.currentIndex === 2 ? "selected" : ""
                onClicked: {
                    if (privateProps.currentIndex !== 2)
                        privateProps.currentIndex = 2
                    element.loadElement("ScreenSaverTypes.qml", name)
                }
            }
        }

        Column {
            // type item: it is a static list of all possible screen saver types
            AnimatedLoader {
                id: screenSaverLoader
            }
        }
    }

    Component {
        id: noneItem
        Column {
            ControlChoices {
                description: qsTr("turn off display")
                choice: pageObject.names.get('TURN_OFF_DISPLAY_LIST', 5)
                property int currentIndex: 5
                onPlusClicked: {
                    if (currentIndex < 9) {
                        choice = pageObject.names.get('TURN_OFF_DISPLAY_LIST', ++currentIndex)
                    }
                }
                onMinusClicked: {
                    if (currentIndex >= 0) {
                        choice = pageObject.names.get('TURN_OFF_DISPLAY_LIST', --currentIndex)
                    }
                }
            }
            ButtonOkCancel {
                // TODO manage OK and Cancel buttons
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
                    text: qsTr("Browse")
                    anchors.fill: parent
                }
            }
            ControlChoices {
                description: qsTr("screen saver time out")
                choice: pageObject.names.get('SCREEN_SAVER_TIMEOUT', 5)
                property int currentIndex: 5
                onPlusClicked: {
                    if (currentIndex < 8) {
                        choice = pageObject.names.get('SCREEN_SAVER_TIMEOUT', ++currentIndex)
                    }
                }
                onMinusClicked: {
                    if (currentIndex >= 0) {
                        choice = pageObject.names.get('SCREEN_SAVER_TIMEOUT', --currentIndex)
                    }
                }
            }
            ControlChoices {
                description: qsTr("turn off display")
                choice: pageObject.names.get('TURN_OFF_DISPLAY_LIST', 5)
                property int currentIndex: 5
                onPlusClicked: {
                    if (currentIndex < 9) {
                        choice = pageObject.names.get('TURN_OFF_DISPLAY_LIST', ++currentIndex)
                    }
                }
                onMinusClicked: {
                    if (currentIndex >= 0) {
                        choice = pageObject.names.get('TURN_OFF_DISPLAY_LIST', --currentIndex)
                    }
                }
            }
            ButtonOkCancel {
                // TODO manage OK and Cancel buttons
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
                    text: qsTr("Change text")
                    anchors.fill: parent
                }
            }
            ControlChoices {
                description: qsTr("screen saver time out")
                choice: pageObject.names.get('SCREEN_SAVER_TIMEOUT', 5)
                property int currentIndex: 5
                onPlusClicked: {
                    if (currentIndex < 8) {
                        choice = pageObject.names.get('SCREEN_SAVER_TIMEOUT', ++currentIndex)
                    }
                }
                onMinusClicked: {
                    if (currentIndex >= 0) {
                        choice = pageObject.names.get('SCREEN_SAVER_TIMEOUT', --currentIndex)
                    }
                }
            }
            ControlChoices {
                description: qsTr("turn off display")
                choice: pageObject.names.get('TURN_OFF_DISPLAY_LIST', 5)
                property int currentIndex: 5
                onPlusClicked: {
                    if (currentIndex < 9) {
                        choice = pageObject.names.get('TURN_OFF_DISPLAY_LIST', ++currentIndex)
                    }
                }
                onMinusClicked: {
                    if (currentIndex >= 0) {
                        choice = pageObject.names.get('TURN_OFF_DISPLAY_LIST', --currentIndex)
                    }
                }
            }
            ButtonOkCancel {
                // TODO manage OK and Cancel buttons
            }
        }
    }

    Component {
        id: dateTimeItem
        Column {
            ControlChoices {
                description: qsTr("screen saver time out")
                choice: pageObject.names.get('SCREEN_SAVER_TIMEOUT', 5)
                property int currentIndex: 5
                onPlusClicked: {
                    if (currentIndex < 8) {
                        choice = pageObject.names.get('SCREEN_SAVER_TIMEOUT', ++currentIndex)
                    }
                }
                onMinusClicked: {
                    if (currentIndex >= 0) {
                        choice = pageObject.names.get('SCREEN_SAVER_TIMEOUT', --currentIndex)
                    }
                }
            }
            ControlChoices {
                description: qsTr("turn off display")
                choice: pageObject.names.get('TURN_OFF_DISPLAY_LIST', 5)
                property int currentIndex: 5
                onPlusClicked: {
                    if (currentIndex < 9) {
                        choice = pageObject.names.get('TURN_OFF_DISPLAY_LIST', ++currentIndex)
                    }
                }
                onMinusClicked: {
                    if (currentIndex >= 0) {
                        choice = pageObject.names.get('TURN_OFF_DISPLAY_LIST', --currentIndex)
                    }
                }
            }
            ButtonOkCancel {
                // TODO manage OK and Cancel buttons
            }
        }
    }
}
