import QtQuick 1.1
import Components 1.0
import "../../js/Stack.js" as Stack


MenuColumn {
    id: column

    Component {
        id: skin
        Skin {}
    }

    Component {
        id: backgroundImage
        Item {}
    }

    function alertOkClicked() {
        skinItem.description = pageObject.names.get('SKIN', privateProps.skin);
        global.guiSettings.skin = privateProps.skin
        Stack.backToHome()
    }

    // we don't have a ListView, so we don't have a currentIndex property: let's define it
    QtObject {
        id: privateProps
        property int currentIndex: -1
        property int skin: -1
    }

    onChildDestroyed: privateProps.currentIndex = -1

    onChildLoaded: {
        if (child.skinChanged)
            child.skinChanged.connect(skinChanged)
    }

    function skinChanged(value) {
        // TODO assign to a model property
        //privateProps.model.TextLanguage = value;
        // TODO remove when model is implemented
        privateProps.skin = value
        pageObject.showAlert(column, qsTr("The selected action will produce a reboot of the GUI. Continue?"))
    }

    PaginatorColumn {
        id: paginator
        anchors.horizontalCenter: parent.horizontalCenter
        maxHeight: 300

        MenuItem {
            id: skinItem
            name: qsTr("skin home")
            description: pageObject.names.get('SKIN', global.guiSettings.skin)
            hasChild: true
            isSelected: privateProps.currentIndex === 1
            onClicked: {
                if (privateProps.currentIndex !== 1)
                    privateProps.currentIndex = 1
                column.loadColumn(skin, name)
            }
        }

        MenuItem {
            name: qsTr("Modify background image")
            isSelected: privateProps.currentIndex === 2
            onClicked: {
                if (privateProps.currentIndex !== 2)
                    privateProps.currentIndex = 2
                console.log("Implement modify background image feature")
            }
        }

        MenuItem {
            name: qsTr("Add Quicklink")
            isSelected: privateProps.currentIndex === 3
            onClicked: {
                if (privateProps.currentIndex !== 3)
                    privateProps.currentIndex = 3
                console.log("Implement add quicklink in home page (static uii?)")
//                Stack.pushPage("AddQuicklink.qml", {"profile": column.dataModel})
            }
        }
     }
}
