import QtQuick 1.1

MenuElement {
    id: element
    width: 212
    height: sourceSelect.height + itemLoader.height

    MenuItem {
        id: sourceSelect
        anchors.top: parent.top
        name: "radio"
        hasChild: true
        state: privateProps.currentElement === 0 ? "selected" : ""
        onClicked: {
            if (privateProps.currentElement !== 0)
                privateProps.currentElement = 0
            element.loadElement("SourceList.qml", qsTr("source change"))
        }
    }

    AnimatedLoader {
        id: itemLoader
        anchors.bottom: parent.bottom
    }

    // TODO: since we start off from radio, this will make the mockup prettier
    Component.onCompleted: sourceSelected({name: "radio"})

    onChildLoaded: {
        element.child.sourceSelected.connect(element.sourceSelected)
    }

    onChildDestroyed: privateProps.currentElement = -1

    QtObject {
        id: privateProps
        property int currentElement: -1
    }

    function sourceSelected(obj) {
        sourceSelect.name = obj.name
        var properties = {'objModel': obj}

        if (obj.name === "radio")
        {
            itemLoader.setComponent(fmRadio, properties)
        }
        else if (obj.name === "webradio")
        {
            itemLoader.setComponent(ipRadio, properties)
        }
        else
        {
            itemLoader.setComponent(mediaPlayer, properties)
        }
    }

    Component {
        id: fmRadio
        Column {
            property variant objModel: undefined
            ControlFMRadio {

            }

            Image {
                width: 212
                height: 200
                source: "images/sound_diffusion/bg_StazioniMemorizzate.png"

                // TODO: must be linked with model and probably revised
                Grid {
                    columns: 5
                    rows: 3
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        bottom: parent.bottom
                        bottomMargin: 5
                    }

                    ButtonFMStation {
                        stationNumber: 1
                        state: "saved"
                    }
                    ButtonFMStation {
                        stationNumber: 2
                        state: "saved"
                    }
                    ButtonFMStation {
                        stationNumber: 3
                        state: "saved"
                    }
                    ButtonFMStation {
                        stationNumber: 4
                        state: "playing"
                    }
                    ButtonFMStation {
                        stationNumber: 5
                        state: "saved"
                    }

                    ButtonFMStation {
                        stationNumber: 6
                        state: "saved"
                    }
                    ButtonFMStation {
                        stationNumber: 7
                        state: "saved"
                    }
                    ButtonFMStation {
                        stationNumber: 8
                    }
                    ButtonFMStation {
                        stationNumber: 9
                    }
                    ButtonFMStation {
                        stationNumber: 10
                    }

                    ButtonFMStation {
                        stationNumber: 11
                    }
                    ButtonFMStation {
                        stationNumber: 12
                    }
                    ButtonFMStation {
                        stationNumber: 13
                    }
                    ButtonFMStation {
                        stationNumber: 14
                    }
                    ButtonFMStation {
                        stationNumber: 15
                    }
                }
            }
        }
    }

    Component {
        id: ipRadio
        Column {
            property variant objModel: undefined
            MenuItem {
                name: qsTr("saved IP radios")
                hasChild: true
                state: privateProps.currentElement === 1 ? "selected" : ""
                onClicked: {
                    if (privateProps.currentElement !== 1)
                        privateProps = 1
                    console.log("cliccato su " + name)
                }
            }

            ControlIPRadio {

            }
        }
    }

    Component {
        id: mediaPlayer
        Column {
            property variant objModel: undefined
            MenuItem {
                name: qsTr("browse")
                hasChild: true
                state: privateProps.currentElement === 1 ? "selected" : ""
                onClicked: {
                    if (privateProps.currentElement !== 1)
                        privateProps.currentElement = 1
                    element.loadElement("SongBrowser.qml", "Browse")
                }
            }

            ControlMediaPlayer {

            }
        }
    }
}
