import QtQuick 1.1

MenuElement {
    id: element
    width: 212

    MenuItem {
        id: sourceSelect
        name: "Current source"
        hasChild: true
        active: element.animationRunning === false
        onClicked: sourceSelected({name: "radio"})//element.loadElement("SourceList.qml", qsTr("source change"))
    }

    function sourceSelected(obj) {
        sourceSelect.name = obj.name
        var properties = {'objModel': obj}
        itemLoader.setComponent(fmRadio, properties)
    }

    Component {
        id: fmRadio
        Column {
            property variant objModel: undefined
            ControlFMRadio {

            }
        }
    }

    Loader {
        id: sourceControl
        anchors.top: sourceSelect.bottom
        visible: false
        source: "components/MenuItem.qml"
        onLoaded: {
            item.name = "browse"
        }
    }

    AnimatedLoader {
        id: itemLoader
        anchors.top: sourceControl.visible ? sourceControl.bottom : sourceSelect.bottom
    }


}
