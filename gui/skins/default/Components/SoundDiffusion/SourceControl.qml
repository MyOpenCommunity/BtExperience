/*
 * Copyright © 2011-2013 BTicino S.p.A.
 *
 * This file is part of BtExperience.
 *
 * BtExperience is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BtExperience is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BtExperience. If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 1.1
import BtObjects 1.0
import BtExperience 1.0
import Components 1.0
import Components.Text 1.0
import "../../js/MediaItem.js" as Script


MenuColumn {
    id: column

    property string imagesPath: "../../images/"

    SourceModel { id: sourceModel }

    Column {
        MenuItem {
            id: sourceSelect
            name: qsTr("source")
            description: column.dataModel.currentSource ? column.dataModel.currentSource.name : "---"
            hasChild: true
            isSelected: privateProps.currentIndex === 0
            onTouched: {
                if (privateProps.currentIndex !== 0)
                    privateProps.currentIndex = 0
                column.loadColumn(sourceList, qsTr("Source changed"))
            }
        }

        AnimatedLoader {
            id: itemLoader
        }
    }

    QtObject {
        id: privateProps
        property int currentIndex: -1
        property bool okClicked: false

        function updateSourceItem(sourceObj) {
            if (itemLoader.item && itemLoader.item.objModel === sourceObj)
                return

            var properties = {'objModel': sourceObj}

            switch (sourceObj.sourceType)
            {
            case SourceObject.RdsRadio:
                itemLoader.setComponent(fmRadio, properties)
                break
            case SourceObject.Aux:
            case SourceObject.Touch:
                itemLoader.setComponent(auxComponent, properties)
                break
            case SourceObject.IpRadio:
                itemLoader.setComponent(ipRadio, properties)
                break
            default:
                itemLoader.setComponent(mediaPlayer, properties)
                break
            }
            column.closeChild()
        }

        function sourceSelected(sourceObj) {
            updateSourceItem(sourceObj)

            if (column.dataModel.objectId === ObjectInterface.IdMultiGeneral)
                sourceObj.setActiveGeneral(column.dataModel.area)
            else
                sourceObj.setActive(column.dataModel.area)
        }
    }

    Component {
        id: fmRadio
        Column {
            id: radioColumn
            property variant objModel: undefined

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
                property bool beepStateEnabled: false

                source: objModel.source.savedStationsCount === 5 ? imagesPath + "sound_diffusion/bg_5stazioni_radio.svg" :
                                                                   imagesPath + "sound_diffusion/bg_15stazioni_radio.svg"
                Grid {
                    id: grid
                    columns: 5
                    rows: objModel.source.savedStationsCount / columns
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
                                pressAndHoldEnabled: true
                                onHeld: {
                                    objModel.source.saveStation(stationNumber)
                                    global.beep()
                                }
                            }
                        }
                    }
                }

                // We want to beep when a radio station is saved; we need to
                // enable the beep state and disable it if was previously disabled
                Component.onCompleted: {
                    beepStateEnabled = global.audioState.isStateEnabled(AudioState.Beep)
                    global.audioState.enableState(AudioState.Beep)
                }

                Component.onDestruction: {
                    if (!beepStateEnabled)
                        global.audioState.disableState(AudioState.Beep)
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
                onTouched: {
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

            function startBrowsing() {
                if (privateProps.currentIndex !== 1)
                    privateProps.currentIndex = 1
                var comp = objModel.sourceType === SourceObject.Upnp ? upnpBrowser : directoryBrowser
                var props = {rootPath: objModel.rootPath,
                    upnp: objModel.sourceType === SourceObject.Upnp,
                }
                column.loadColumn(comp, browseItem.name, objModel, props)
            }

            MenuItem {
                id: browseItem
                name: qsTr("browse")
                hasChild: true
                isSelected: privateProps.currentIndex === 1
                // if we are playing Upnp, enable browsing
                enabled: global.upnpStatus === GlobalProperties.UpnpSoundDiffusion ? true : Script.mediaItemEnabled(objModel)
                onEnabledChanged: column.closeChild()
                onTouched: {
                    if (objModel.sourceType === SourceObject.Upnp &&
                            global.upnpStatus !== GlobalProperties.UpnpSoundDiffusion &&
                            global.upnpStatus !== GlobalProperties.UpnpInactive) {
                        pageObject.installPopup(upnpDialog)
                    }
                    else
                        mediaPlayerColumn.startBrowsing()
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
                song: trackInfo['meta_title'] || trackInfo['file_name'] || qsTr("no title")
                album: trackInfo['meta_album'] || qsTr("no album")
                playerStatus: objModel.mediaPlayer.playerState

                onPlayClicked: objModel.togglePause()
                onPreviousClicked: {
                    if (goToPrevTrack.running) {
                        goToPrevTrack.restart()
                        objModel.previousTrack()
                    } else {
                        goToPrevTrack.start()
                        objModel.restart()
                    }
                }

                onNextClicked: objModel.nextTrack()

                Timer {
                    id: goToPrevTrack
                    interval: 5000
                }
            }
        }
    }

    Component {
        id: auxComponent

        SvgImage {
            id: control
            property variant objModel: undefined
            source: imagesPath + "common/bg_on-off.svg"

            Row {
                anchors.centerIn: parent
                ButtonImageThreeStates {
                    defaultImageBg: imagesPath + "common/btn_99x35.svg"
                    pressedImageBg: imagesPath + "common/btn_99x35_P.svg"
                    shadowImage: imagesPath + "common/btn_shadow_99x35.svg"
                    defaultImage: imagesPath + "sound_diffusion/ico_indietro.svg"
                    pressedImage: imagesPath + "sound_diffusion/ico_indietro_P.svg"

                    onPressed: objModel.previousTrack()
                }
                ButtonImageThreeStates {
                    defaultImageBg: imagesPath + "common/btn_99x35.svg"
                    pressedImageBg: imagesPath + "common/btn_99x35_P.svg"
                    shadowImage: imagesPath + "common/btn_shadow_99x35.svg"
                    defaultImage: imagesPath + "sound_diffusion/ico_avanti.svg"
                    pressedImage: imagesPath + "sound_diffusion/ico_avanti_P.svg"

                    onPressed: objModel.nextTrack()
                }
            }
        }
    }

    Component {
        id: sourceList
        SourceList {}
    }

    Component {
        id: upnpBrowser
        ColumnBrowserUpnpModel {
            typeFilterEnabled: false
            filter: FileObject.Audio | FileObject.Directory
            onAudioClicked: dataModel.startUpnpPlay(theModel, index, theModel.count)
        }
    }

    Component {
        id: directoryBrowser
        ColumnBrowserDirectoryModel {
            typeFilterEnabled: false
            filter: FileObject.Audio | FileObject.Directory
            onAudioClicked: dataModel.startPlay(theModel, index, theModel.count)
        }
    }

    Component {
        id: radioList
        IpRadioList {}
    }

    Connections {
        target: column.pageObject
        onPopupDismissed: {
            if (privateProps.okClicked) {
                itemLoader.item.startBrowsing()
                privateProps.okClicked = false
            }
        }
    }

    Component {
        id: upnpDialog

        TextDialog {
            title: qsTr("Multimedia is playing")
            text: qsTr("UPnP support is limited to only one active source. \
The UPnP source is busy in multimedia. Do you want to stop the multimedia \
source?")
            function okClicked() {
                global.audioVideoPlayer.terminate()
                privateProps.okClicked = true
            }
            function cancelClicked() {
                privateProps.okClicked = false
            }
        }
    }

    Connections {
        target: column.child
        ignoreUnknownSignals: true
        onSourceSelected: privateProps.sourceSelected(object)
    }

    Connections {
        target: dataModel
        onCurrentSourceChanged: {
            if (column.dataModel.currentSource) {
                privateProps.updateSourceItem(column.dataModel.currentSource)
            }
            else {
                column.closeChild()
                itemLoader.destroyComponent()
            }
        }
    }

    Component.onCompleted: {
        if (column.dataModel.currentSource)
            privateProps.updateSourceItem(column.dataModel.currentSource)
    }

    onChildDestroyed: privateProps.currentIndex = -1
}
