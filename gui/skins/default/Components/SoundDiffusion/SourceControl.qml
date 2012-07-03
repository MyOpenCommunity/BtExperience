import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Text 1.0


MenuColumn {
    id: column

    Component {
        id: sourceList
        SourceList {}
    }

    Component {
        id: songBrowser
        SongBrowser {}
    }

    width: 212
    height: sourceSelect.height + itemLoader.height
    property string imagesPath: "../../images/"

    MenuItem {
        id: sourceSelect
        anchors.top: parent.top
        name: "radio"
        hasChild: true
        state: privateProps.currentElement === 0 ? "selected" : ""
        onClicked: {
            if (privateProps.currentElement !== 0)
                privateProps.currentElement = 0
            column.loadColumn(sourceList, qsTr("source change"))
        }
    }

    AnimatedLoader {
        id: itemLoader
        anchors.bottom: parent.bottom
    }

    Component.onCompleted: {
        if (column.dataModel.currentSource)
            sourceSelected(column.dataModel.currentSource)
    }

    onChildLoaded: {
        column.child.sourceSelected.connect(column.sourceSelected)
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
        sourceObj.setActive(column.dataModel.area)

        column.closeChild()
    }

    Component {
        id: fmRadio
        Column {
            id: radioColumn
            property variant objModel: undefined
            property int maxStations: 15


            ControlFMRadio {
                radioName: "radio - " + objModel.rdsText
                radioFrequency: objModel.currentFrequency

                // TODO: assume we only want automatic frequency search
                onNextTrack: objModel.searchUp()
                onPreviousTrack: objModel.searchDown()
            }

            Image {
                source: radioColumn.maxStations === 5 ? imagesPath + "sound_diffusion/bg_5stazioni_radio.svg" :
                                                        imagesPath + "sound_diffusion/bg_15stazioni_radio.svg"
                Grid {
                    id: grid
                    columns: 5
                    rows: radioColumn.maxStations / columns
                    spacing: 3
                    anchors {
                        top: parent.top
                        topMargin: 10
                        left: parent.left
                        leftMargin: 7
                    }

                    Repeater {
                        model: grid.rows * grid.columns

                        Item {
                            height: button.height + 5
                            width: button.width

                            ButtonThreeStates {
                                id: button
                                property int stationNumber: index + 1

                                defaultImage: "../../images/sound_diffusion/btn_37x45.svg"
                                pressedImage: "../../images/sound_diffusion/btn_37x45_P.svg"
                                selectedImage: "../../images/sound_diffusion/btn_37x45_S.svg"
                                shadowImage: "../../images/sound_diffusion/btn_37x45_shadow.svg"
                                text: stationNumber
                                status: objModel.currentStation === stationNumber ? 1 : 0
                                textAnchors.centerIn: null
                                textAnchors.top: button.top
                                textAnchors.topMargin: 8
                                textAnchors.horizontalCenter: button.horizontalCenter
                                font.pixelSize: 12

                                onClicked: radioColumn.objModel.currentStation = stationNumber
                            }
                        }
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
                    column.loadColumn(songBrowser, "Browse")
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

            source: imagesPath + "common/bg_UnaRegolazione.png"

            UbuntuLightText {
                y: 10
                font.bold: true
                font.pixelSize: 16
                anchors.horizontalCenter: control.horizontalCenter
                text: objModel.currentTrack
            }

        }
    }
}
