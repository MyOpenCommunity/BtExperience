import QtQuick 1.1

MenuElement {
    id: element
    width: 212
    height: sourceSelect.height + itemLoader.height + (sourceControl.sourceComponent !== null ? sourceControl.height : 0)

    MenuItem {
        id: sourceSelect
        anchors.top: parent.top
        name: "Current source"
        hasChild: true
        active: element.animationRunning === false
        onClicked: element.loadElement("SourceList.qml", qsTr("source change"))
    }

    Loader {
        id: sourceControl
        anchors.top: sourceSelect.bottom
        sourceComponent: extraButton
    }

    AnimatedLoader {
        id: itemLoader
        anchors.bottom: parent.bottom
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
            sourceControl.sourceComponent = null
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

}
