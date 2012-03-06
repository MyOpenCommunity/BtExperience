import QtQuick 1.1

MenuElement {
    id: element
    width: 212
    // the Loader doesn't change its height when the internal item is reset and
    // I can't set the height by hand otherwise the binding is broken and it's
    // not automatically updated anymore.
    height: sourceSelect.height + itemLoader.height + (sourceControl.opacity ? sourceControl.height : 0)

    Column {
        id: controls
        MenuItem {
            id: sourceSelect
            name: "Current source"
            hasChild: true
            active: element.animationRunning === false
            onClicked: element.loadElement("SourceList.qml", qsTr("source change"))
        }

        Loader {
            id: sourceControl
            sourceComponent: extraButton
        }
    }

    AnimatedLoader {
        id: itemLoader
        anchors.top: controls.bottom
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
            sourceControl.opacity = 0
        }
        else if (obj.name === "webradio")
        {
            itemLoader.setComponent(ipRadio, properties)
            sourceControl.sourceComponent = extraButton
            sourceControl.opacity = 1
        }
        else
        {
            itemLoader.setComponent(mediaPlayer, properties)
            sourceControl.sourceComponent = extraButton
            sourceControl.opacity = 1
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

}
