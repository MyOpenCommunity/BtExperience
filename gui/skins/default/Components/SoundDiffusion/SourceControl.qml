import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Text 1.0


MenuColumn {
    id: column
    property string imagesPath: "../../images/"

    width: 212
    height: sourceSelect.height + itemLoader.height

    MenuItem {
        id: sourceSelect
        anchors.top: parent.top
        name: qsTr("source")
        description: column.dataModel.currentSource === null ? qsTr("no active source") : column.dataModel.currentSource.name
        hasChild: true
        isSelected: privateProps.currentIndex === 0
        onClicked: {
            if (privateProps.currentIndex !== 0)
                privateProps.currentIndex = 0
            column.loadColumn(sourceList, qsTr("source change"))
        }
    }

    AnimatedLoader {
        id: itemLoader
        anchors.bottom: parent.bottom
    }

    QtObject {
        id: privateProps
        property int currentIndex: -1

        function sourceSelected(sourceObj) {
            sourceSelect.description = sourceObj.name
            var properties = {'objModel': sourceObj}

            switch (sourceObj.sourceType)
            {
            case SourceObject.RdsRadio:
                itemLoader.setComponent(fmRadio, properties)
                break
            case SourceObject.Aux:
                itemLoader.setComponent(auxComponent, properties)
                break
            case SourceObject.IpRadio:
                itemLoader.setComponent(ipRadio, properties)
                break
            default:
                itemLoader.setComponent(mediaPlayer, properties)
                break
            }
            sourceObj.setActive(column.dataModel.area)

            column.closeChild()
        }
    }

    Component {
        id: fmRadio
        Column {
            id: radioColumn
            property variant objModel: undefined
            property int maxStations: 15

            ControlFMRadio {
                radioName: "radio - " + objModel.source.rdsText
                radioFrequency: objModel.source.currentFrequency
                stationNumber: objModel.source.currentStation

                onNextTrack: objModel.source.searchUp()
                onPreviousTrack: objModel.source.searchDown()

                Component.onCompleted: objModel.source.startRdsUpdates()
                Component.onDestruction: objModel.source.stopRdsUpdates()
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
                                status: objModel.source.currentStation === stationNumber ? 1 : 0
                                textAnchors.centerIn: null
                                textAnchors.top: button.top
                                textAnchors.topMargin: 8
                                textAnchors.horizontalCenter: button.horizontalCenter
                                font.pixelSize: 12

                                onClicked: radioColumn.objModel.source.currentStation = stationNumber
                                onPressAndHold: objModel.source.saveStation(stationNumber)
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
            id: ipRadioColumn
            property variant objModel: undefined
            MenuItem {
                name: qsTr("saved IP radios")
                hasChild: true
                isSelected: privateProps.currentIndex === 1
                onClicked: {
                    if (privateProps.currentIndex !== 1)
                        privateProps = 1
                    column.loadColumn(radioList, name, ipRadioColumn.objModel)
                }
            }

            ControlIPRadio {
                property variant trackInfo: objModel.mediaPlayer.trackInfo

                radioTitle: trackInfo['stream_title'] === undefined ? qsTr("no title") : trackInfo['stream_title']
                playerStatus: objModel.mediaPlayer.playerState
                onPlayClicked: objModel.togglePause()
                onPreviousClicked: objModel.previousTrack()
                onNextClicked: objModel.nextTrack()
            }
        }
    }

    Component {
        id: mediaPlayer
        Column {
            id: mediaPlayerColumn
            property variant objModel: undefined
            MenuItem {
                name: qsTr("browse")
                hasChild: true
                isSelected: privateProps.currentIndex === 1
                onClicked: {
                    if (privateProps.currentIndex !== 1)
                        privateProps.currentIndex = 1
                    var comp = objModel.sourceType === SourceObject.FileSystem ? directoryBrowser : upnpBrowser
                    var props = {"rootPath": objModel.rootPath}
                    column.loadColumn(comp, name, mediaPlayerColumn.objModel, props)
                }
            }

            ControlMediaPlayer {
                property variant trackInfo: objModel.mediaPlayer.trackInfo
                function formatTime(time) {
                    if (time === undefined)
                        return "--:--"
                    // TODO: this way we can't show songs 1h or more long even though
                    // we support 99 minutes in the GUI.
                    // I couldn't find a way to access hours and minutes, it doesn't
                    // seem to be accessible as a JS Date object (it's a QTime in fact)
                    return Qt.formatTime(time, "mm:ss")
                }

                time: formatTime(trackInfo['current_time'])
                song: trackInfo['meta_title'] === undefined ? qsTr("no title") : trackInfo['meta_title']
                album: trackInfo['meta_album'] === undefined ? qsTr("no album") : trackInfo['meta_album']
                playerStatus: objModel.mediaPlayer.playerState

                onPlayClicked: objModel.togglePause()
                onPreviousClicked: objModel.previousTrack()
                onNextClicked: objModel.nextTrack()
            }
        }
    }

    Component {
        id: auxComponent

        Image {
            id: control
            property variant objModel: undefined
            width: 212
            height: 100
            source: imagesPath + "common/bg_UnaRegolazione.png"

            UbuntuLightText {
                y: 10
                font.bold: true
                font.pixelSize: 16
                anchors.horizontalCenter: control.horizontalCenter
                text: objModel.source.currentTrack
            }

        }
    }

    Component {
        id: sourceList
        SourceList {}
    }

    Component {
        id: upnpBrowser
        UPnPBrowser {}
    }

    Component {
        id: directoryBrowser
        DirectoryBrowser {}
    }

    Component {
        id: radioList
        IpRadioList {}
    }

    Connections {
        target: column.child
        ignoreUnknownSignals: true
        onSourceSelected: privateProps.sourceSelected(object)
    }

    Component.onCompleted: {
        if (column.dataModel.currentSource)
            privateProps.sourceSelected(column.dataModel.currentSource)
    }

    onChildDestroyed: privateProps.currentIndex = -1
}
