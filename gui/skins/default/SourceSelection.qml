import QtQuick 1.1
import BtObjects 1.0

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

    Component.onCompleted: {
        if (element.dataModel.currentSource)
            sourceSelected(element.dataModel.currentSource)
    }

    onChildLoaded: {
        element.child.sourceSelected.connect(element.sourceSelected)
    }

    onChildDestroyed: privateProps.currentElement = -1

    QtObject {
        id: privateProps
        property int currentElement: -1
    }

    function sourceSelected(sourceObj) {
        sourceSelect.name = sourceObj.name
        var properties = {'objModel': sourceObj}

        switch (sourceObj.type)
        {
        case SourceBase.Radio:
            itemLoader.setComponent(fmRadio, properties)
            break
        case SourceBase.Aux:
            itemLoader.setComponent(auxComponent, properties)
            break
        default:
            itemLoader.setComponent(mediaPlayer, properties)
            break
        }
        sourceObj.setActive(element.dataModel.area)

        element.closeChild()
    }

    Component {
        id: fmRadio
        Column {
            property variant objModel: undefined
            ControlFMRadio {
                radioName: "radio - " + objModel.rdsText
                radioFrequency: objModel.currentFrequency

                // TODO: assume we only want automatic frequency search
                onNextTrack: objModel.searchUp()
                onPreviousTrack: objModel.searchDown()
            }

            Image {
                width: 212
                height: 200
                source: "images/sound_diffusion/bg_StazioniMemorizzate.png"

                Row {
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        top: parent.top
                        topMargin: 5
                    }

                    ButtonFMStation {
                        stationNumber: 1
                        state: objModel.currentStation === stationNumber ? "playing" : "saved"
                        onStationSelected: objModel.currentStation = stationNumber
                    }
                    ButtonFMStation {
                        stationNumber: 2
                        state: objModel.currentStation === stationNumber ? "playing" : "saved"
                        onStationSelected: objModel.currentStation = stationNumber
                    }
                    ButtonFMStation {
                        stationNumber: 3
                        state: objModel.currentStation === stationNumber ? "playing" : "saved"
                        onStationSelected: objModel.currentStation = stationNumber
                    }
                    ButtonFMStation {
                        stationNumber: 4
                        state: objModel.currentStation === stationNumber ? "playing" : "saved"
                        onStationSelected: objModel.currentStation = stationNumber
                    }
                    ButtonFMStation {
                        stationNumber: 5
                        state: objModel.currentStation === stationNumber ? "playing" : "saved"
                        onStationSelected: objModel.currentStation = stationNumber
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

    Component {
        id: auxComponent

        Image {
            id: control
            width: 212
            height: 100
            property variant objModel: undefined

            source: "images/common/bg_UnaRegolazione.png"

            Text {
                y: 10
                font.bold: true
                font.pointSize: 12
                anchors.horizontalCenter: control.horizontalCenter
                text: objModel.currentTrack
            }

        }
    }
}
