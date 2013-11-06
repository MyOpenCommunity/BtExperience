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
import Components.Popup 1.0
import Components.Text 1.0
import Components.SoundDiffusion 1.0
import "js/Stack.js" as Stack
import "js/MediaPlayerHelper.js" as Helper


/**
  \ingroup Multimedia

  \brief An audio player page to play audio files.

  This page shows an audio player component. This component controls audio
  files rendering. The user can operate the usual play, pause, stop functions.
  The list of available functions is:
  - previous track
  - next track
  - play
  - pause
  - resume
  - stop
  - mute
  - volume up
  - volume down
  - seek backward
  - seek forward

  The player shows some track informations (like title or duration), too (when available).
  A progress indicator is also shown and visualizes the play progress on actual track.
  The player manages a list of tracks and play them in a continous loop.

  If the user leaves the page without stopping the player, the execution goes on
  until the user comes back to the audio player page and explicitly stops it.
  When the audio player is playing, a toolbar button appears to quickly
  navigate to this page.
  */
Page {
    id: player

    /** the model implementing a play list of audio files */
    property variant model
    /** a track belonging to the play list is identified by this index */
    property int index
    /** is the play list read from a media server? */
    property bool upnp
    /** the C++ model object controlling the audio player functionality */
    property variant mediaPlayer: global.audioVideoPlayer

    /**
      Called when systems button on navigation bar is clicked.
      Navigates back to multimedia page.
      */
    function systemsButtonClicked() {
        Stack.backToMultimedia()
    }

    /**
      Called when back button on navigation bar is clicked.
      Navigates back to multimedia page.
      */
    function backButtonClicked() {
        Stack.backToMultimedia()
    }

    source: "images/background/multimedia.jpg"
    showSystemsButton: true
    text: qsTr("Audio")

    SvgImage {
        id: frameBg
        source: "images/common/video_player_bg_frame.svg"
        visible: false
    }

    SvgImage {
        id: bottomBarBg

        source: "images/common/video_player_bg_box.svg"
        anchors {
            horizontalCenter: player.horizontalCenter
            verticalCenter: player.verticalCenter
        }
    }

    UbuntuLightText {
        id: title

        text: privateProps.buildTrackText(player.mediaPlayer.trackInformation)
        color: "white"
        font.pixelSize: frameBg.height / 100 * 3.63
        anchors {
            top: bottomBarBg.top
            topMargin: frameBg.height / 100 * 1.81
            left: bottomBarBg.left
            leftMargin: frameBg.width / 100 * 2.48
            right: duration.left
            rightMargin: 20
        }
        elide: Text.ElideLeft
    }

    UbuntuLightText {
        id: duration

        text: player.mediaPlayer.currentTime + " / " + player.mediaPlayer.totalTime
        color: "#323232"
        horizontalAlignment: Text.AlignRight
        font.pixelSize: frameBg.height / 100 * 3.63
        anchors {
            top: bottomBarBg.top
            topMargin: frameBg.height / 100 * 1.81
            right: bottomBarBg.right
            rightMargin: frameBg.width / 100 * 2.48
        }
    }

    SvgImage {
        id: imageSlider

        source: "images/common/bg_tempo.svg"
        anchors {
            top: bottomBarBg.top
            topMargin: frameBg.height / 100 * 8.29
            horizontalCenter: bottomBarBg.horizontalCenter
        }

        Rectangle {
            height: imageSlider.height + 2
            width: imageSlider.width * (player.mediaPlayer.percentage < 1 ? 1 : player.mediaPlayer.percentage) / 100 + 4
            radius: 100
            smooth: true
            anchors {
                verticalCenter: imageSlider.verticalCenter
                left: imageSlider.left
                leftMargin: -2
            }
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: "#a9abad"
                }
                GradientStop {
                    position: 1.0
                    color: "#5c5c5c"
                }
            }
            Behavior on width {
                NumberAnimation { duration: 200 }
            }
        }
    }

    Row {
        id: playerControl
        spacing: frameBg.width / 100 * 0.58
        anchors {
            top: imageSlider.bottom
            topMargin: frameBg.height / 100 * 1.81
            left: bottomBarBg.left
            leftMargin: frameBg.width / 100 * 2.48
        }


        ButtonImageThreeStates {
            id: prevButton

            defaultImageBg: "images/common/btn_45x35.svg"
            pressedImageBg: "images/common/btn_45x35_P.svg"
            shadowImage: "images/common/btn_shadow_45x35.svg"
            defaultImage: "images/common/ico_previous_track.svg"
            pressedImage: "images/common/ico_previous_track_P.svg"
            repetitionOnHold: true
            slowInterval: 500
            fastInterval: 350

            onClicked: {
                if (repetitionTriggered) {
                    player.mediaPlayer.seek(-10)
                }
                else if (goToPrevTrack.running) {
                    goToPrevTrack.restart()
                    player.mediaPlayer.prevTrack()
                } else {
                    goToPrevTrack.start()
                    player.mediaPlayer.restart()
                }
            }

            Timer {
                id: goToPrevTrack
                interval: 5000
            }
        }

        Item {
            // I used an Item to define some specific states for the playButton
            // please note that playButton is a ButtonImageThreeStates so it defines
            // its internal states, it is neither possible nor desirable to redefine
            // these internal states
            id: playButtonItem

            width: playButton.width
            height: playButton.height

            ButtonImageThreeStates {
                id: playButton

                defaultImageBg: "images/common/btn_45x35.svg"
                pressedImageBg: "images/common/btn_45x35_P.svg"
                shadowImage: "images/common/btn_shadow_45x35.svg"
                defaultImage: "images/common/ico_play.svg"
                pressedImage: "images/common/ico_play_P.svg"
                anchors.centerIn: parent

                onClicked: {
                    if (player.mediaPlayer.playing)
                        player.mediaPlayer.pause()
                    else
                        player.mediaPlayer.resume()
                }
            }

            state: player.mediaPlayer.playing ? "play" : ""

            states: [
                State {
                    name: "play"
                    PropertyChanges {
                        target: playButton
                        defaultImage: "images/common/ico_pause.svg"
                        pressedImage: "images/common/ico_pause_P.svg"
                    }
                }
            ]
        }

        ButtonImageThreeStates {
            id: stopButton

            defaultImageBg: "images/common/btn_45x35.svg"
            pressedImageBg: "images/common/btn_45x35_P.svg"
            shadowImage: "images/common/btn_shadow_45x35.svg"
            defaultImage: "images/common/ico_stop.svg"
            pressedImage: "images/common/ico_stop_P.svg"

            onClicked: {
                player.mediaPlayer.terminate()
                privateProps.goToSourcePage()
            }
        }

        ButtonImageThreeStates {
            id: nextButton

            defaultImageBg: "images/common/btn_45x35.svg"
            pressedImageBg: "images/common/btn_45x35_P.svg"
            shadowImage: "images/common/btn_shadow_45x35.svg"
            defaultImage: "images/common/ico_next_track.svg"
            pressedImage: "images/common/ico_next_track_P.svg"
            repetitionOnHold: true
            slowInterval: 500
            fastInterval: 350

            onClicked: {
                // seek enabled only for audio
                if (repetitionTriggered) {
                    player.mediaPlayer.seek(10)
                }
                else {
                    player.mediaPlayer.nextTrack()
                    // We want to go to previous track within 5 seconds
                    // in the CURRENT track, not 5 seconds globally.
                    // We should really connect to a "new song" signal from the
                    // underlying C++ player, but we don't have a suitable signal,
                    // so let's do it by hand
                    goToPrevTrack.restart()
                }
            }
        }
    }

    ButtonImageThreeStates {
        id: folderButton

        defaultImageBg: "images/common/btn_45x35.svg"
        pressedImageBg: "images/common/btn_45x35_P.svg"
        shadowImage: "images/common/btn_shadow_45x35.svg"
        defaultImage: "images/common/ico_browse.svg"
        pressedImage: "images/common/ico_browse_P.svg"
        anchors {
            top: playerControl.top
            left: playerControl.right
            leftMargin: frameBg.width / 100 * 1.90
        }

        onClicked: privateProps.goToSourcePage()
    }

    ControlAudio {
        anchors {
            top: playerControl.top
            right: bottomBarBg.right
            rightMargin: frameBg.width / 100 * 2.48
        }
        isPlayerMute: player.mediaPlayer.mute
        onMuteClicked: player.mediaPlayer.mute = !player.mediaPlayer.mute
        onDecrementVolume: player.mediaPlayer.decrementVolume()
        onIncrementVolume: player.mediaPlayer.incrementVolume()
    }

    VolumePopup {
        anchors {
            bottom: bottomBarBg.top
            bottomMargin: frameBg.height / 100 * 2.85
            right: bottomBarBg.right
        }
        volume: player.mediaPlayer.volume
        mute: player.mediaPlayer.mute
    }

    Component {
        id: errorFeedback
        FeedbackPopup {
            text: ""
            isOk: false
        }
    }

    Connections {
        target: mediaPlayer
        onVolumeChanged: {
            global.audioState.setVolume(AudioState.LocalPlaybackVolume, mediaPlayer.volume)
        }
        onMuteChanged: {
            if (mediaPlayer.mute)
                global.audioState.enableState(AudioState.LocalPlaybackMute)
            else
                global.audioState.disableState(AudioState.LocalPlaybackMute)
        }
        onLoopDetected: {
            var props = {text: qsTr("Loop detected")}
            if (player.model === undefined) // ip radio
                props = {text: qsTr("No tunable web radio")}

            player.installPopup(errorFeedback, props)
        }
    }

    QtObject {
        id: privateProps
        function buildTrackText(info) {
            var title = ""
            if (info["meta_title"] && info["meta_artist"])
                title = info["meta_title"] + " - " + info["meta_artist"]
            else if (info["meta_title"])
                title = info["meta_title"]
            else if (info["file_name"])
                title = info["file_name"]
            if (player.mediaPlayer.isWebRadio() && info["stream_title"])
                title = info["stream_title"]
            return title
        }

        function goToSourcePage() {
            if (player.mediaPlayer.isWebRadio())
                Stack.goToPage('BrowserPage.qml', {"containerId": Container.IdMultimediaWebRadio, "type": "webradio"})
            else
                Stack.goToPage('Devices.qml', {restoreBrowserState: true})
        }
    }

    Component.onCompleted: Helper.initAudioPlayer(mediaPlayer, model, upnp, index)
}
