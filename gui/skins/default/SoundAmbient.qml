import QtQuick 1.1
import BtObjects 1.0
import "logging.js" as Log

MenuElement {
    id: element
    height: itemList.height + sourceLoader.height
    width: 212

    Component.onCompleted: itemList.currentIndex = -1
    onChildDestroyed: {
        itemList.currentIndex = -1
        privateProps.currentIndex = -1
    }

    Loader {
        id: sourceLoader
        anchors.top: element.top

        property variant itemObject: element.dataModel.currentSource
        sourceComponent: emptySource
        onItemObjectChanged: selectSource(itemObject !== undefined ? itemObject.type : -1)

        function selectSource(sourceType) {
            Log.logDebug("SoundAmbient, sourceType: " + sourceType)
            switch (sourceType) {
            case SourceBase.Radio:
                sourceLoader.sourceComponent = radioSource
                Log.logDebug("Loading radioSource component, obj: " + itemObject)
                break
            case SourceBase.Aux:
                sourceLoader.sourceComponent = auxSource
                Log.logDebug("Loading auxSource component, obj: " + itemObject)
                break
            default:
                Log.logDebug("Source type unknown, default to empty component")
                sourceLoader.sourceComponent = emptySource
                break
            }
        }
    }

    ListView {
        id: itemList
        anchors.bottom: element.bottom
        height: 50 * itemList.count
        interactive: false

        delegate: MenuItemDelegate {
            itemObject: objectModel.getObject(index)

            status: itemObject.active
            hasChild: true
            onDelegateClicked: {
                privateProps.currentIndex = -1
                element.loadElement(objectModel.getComponentFile(itemObject.objectId), itemObject.name, itemObject);
            }
        }

        model: objectModel
    }

    QtObject {
        id: privateProps
        property int currentIndex: -1
    }

    Component {
        id: radioSource

        MenuItem {
            name: qsTr("source")
            description: "radio | " + sourceLoader.itemObject.rdsText
            hasChild: true
            onClicked: {
                privateProps.currentIndex = 1
                itemList.currentIndex = -1
                console.log("radioSource, dataModel: " + element.dataModel)
                element.loadElement("SourceSelection.qml", name, element.dataModel)
            }
            state: privateProps.currentIndex === 1 ? "selected" : ""

            Component.onCompleted: sourceLoader.itemObject.startRdsUpdates()
            Component.onDestruction: sourceLoader.itemObject.stopRdsUpdates()
        }
    }

    Component {
        id: emptySource

        MenuItem {
            name: qsTr("source")
            description: ""
            hasChild: true
            onClicked: {
                privateProps.currentIndex = 1
                itemList.currentIndex = -1
                console.log("emptySource, dataModel: " + element.dataModel)
                element.loadElement("SourceSelection.qml", name, element.dataModel)
            }
            state: privateProps.currentIndex === 1 ? "selected" : ""
        }
    }

    Component {
        id: auxSource

        MenuItem {
            name: qsTr("source")
            description: qsTr("aux")
            hasChild: true
            onClicked: {
                privateProps.currentIndex = 1
                itemList.currentIndex = -1
                console.log("auxSource, dataModel: " + element.dataModel)
                element.loadElement("SourceSelection.qml", name, element.dataModel)
            }
            state: privateProps.currentIndex === 1 ? "selected" : ""
        }
    }

    ObjectModel {
        id: objectModel
        filters: [{objectId: ObjectInterface.IdSoundAmplifierGeneral, objectKey: element.dataModel.objectKey},
            {objectId: ObjectInterface.IdSoundAmplifier, objectKey: element.dataModel.objectKey},
            {objectId: ObjectInterface.IdPowerAmplifier, objectKey: element.dataModel.objectKey}
        ]
    }
}
