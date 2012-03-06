import QtQuick 1.1

MenuElement {
    id: element
    width: 212
    height: sourceSelect.height + itemLoader.height + (sourceControl.item.state !== "" ? sourceControl.height : 0)

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
            sourceControl.item.state = ""
        }
        else if (obj.name === "webradio")
        {
            itemLoader.setComponent(ipRadio, properties)
            sourceControl.item.state = "webradio"
        }
        else
        {
            itemLoader.setComponent(mediaPlayer, properties)
            sourceControl.item.state = "mediaplayer"
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
            id: button
            name: "text"
            active: element.animationRunning === false

            states: [
                State {
                    name: ""
                    PropertyChanges {
                        target: button
                        opacity: 0
                    }
                },
                State {
                    name: "webradio"
                    PropertyChanges {
                        target: button
                        name: qsTr("Saved IP radios")
                        hasChild: true
                        opacity: 1
                        onClicked: console.log("cliccato su " + sourceControl.item.name)
                    }
                },
                State {
                    name: "mediaplayer"
                    PropertyChanges {
                        target: button
                        name: qsTr("browse")
                        hasChild: true
                        opacity: 1
                        onClicked: console.log("cliccato su " + sourceControl.item.name)
                    }
                }
            ]
        }
    }
}
