import QtQuick 1.1

MenuElement {
    id: element
    width: 212

    MenuItem {
        id: sourceSelect
        name: "Current source"
        hasChild: true
        active: element.animationRunning === false
        onClicked: element.loadElement("SourceList.qml", qsTr("source change"))
    }

    onChildLoaded: {
        element.child.sourceSelected.connect(element.sourceSelected)
    }

    function sourceSelected(obj) {
        sourceSelect.name = obj.name
        var properties = {'objModel': obj}

        if (obj.name === "radio")
        {
            itemLoader.setComponent(fmRadio, properties)
            sourceControl.sourceComponent = undefined
        }
        else if (obj.name === "webradio")
        {
            itemLoader.setComponent(ipRadio, properties)
            sourceControl.sourceComponent = extraButton
        }
        else
        {
            itemLoader.setComponent(mediaPlayer, properties)
            sourceControl.sourceComponent = extraButton
        }
    }

    Component {
        id: fmRadio
        Column {
            property variant objModel: undefined
            ControlFMRadio {

            }
        }
    }

    Component {
        id: ipRadio
        Column {
            property variant objModel: undefined
            ControlIPRadio {

            }
        }
    }

    Component {
        id: mediaPlayer
        Column {
            property variant objModel: undefined
            ControlMediaPlayer {

            }
        }
    }

    Component {
        id: extraButton

        MenuItem {
            name: "browse"
        }
    }

    Loader {
        id: sourceControl
        anchors.top: sourceSelect.bottom
        sourceComponent: extraButton
        onHeightChanged: console.log("height: " + height)
    }

    AnimatedLoader {
        id: itemLoader
        anchors.top: sourceControl.visible ? sourceControl.bottom : sourceSelect.bottom
    }
}
