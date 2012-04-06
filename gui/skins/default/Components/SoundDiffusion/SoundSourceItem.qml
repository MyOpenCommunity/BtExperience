import QtQuick 1.1
import Components 1.0
import BtObjects 1.0
import "../../js/logging.js" as Log

Loader {
    id: sourceLoader

    property variant itemObject
    property bool selected: false
    sourceComponent: emptySource
    onItemObjectChanged: selectSource(itemObject !== undefined ? itemObject.type : -1)

    signal itemClicked()

    function selectSource(sourceType) {
        switch (sourceType) {
        case SourceBase.Radio:
            sourceLoader.sourceComponent = radioSource
            break
        case SourceBase.Aux:
            sourceLoader.sourceComponent = auxSource
            break
        default:
            Log.logDebug("Source type " + sourceType + " unknown, default to empty component")
            sourceLoader.sourceComponent = emptySource
            break
        }
    }

    Component {
        id: radioSource

        MenuItem {
            name: qsTr("source")
            property variant sourceObject

            description: "radio | " + sourceLoader.itemObject ? sourceLoader.itemObject.rdsText : ""
            hasChild: true
            onClicked: sourceLoader.itemClicked()
            state: sourceLoader.selected ? "selected" : ""

            Component.onCompleted: {
                sourceObject = sourceLoader.itemObject
                sourceObject.startRdsUpdates()
            }
            Component.onDestruction: sourceObject.stopRdsUpdates()
        }
    }

    Component {
        id: emptySource

        MenuItem {
            name: qsTr("source")
            description: ""
            hasChild: true
            onClicked: sourceLoader.itemClicked()

            state: sourceLoader.selected ? "selected" : ""
        }
    }

    Component {
        id: auxSource

        MenuItem {
            name: qsTr("source")
            description: qsTr("aux")
            hasChild: true
            onClicked: sourceLoader.itemClicked()
            state: sourceLoader.selected ? "selected" : ""
        }
    }
}
