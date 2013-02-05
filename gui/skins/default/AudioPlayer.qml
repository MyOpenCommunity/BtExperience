import QtQuick 1.1
import BtObjects 1.0
import BtExperience 1.0
import Components 1.0
import Components.Popup 1.0
import Components.Text 1.0
import Components.SoundDiffusion 1.0

import "js/Stack.js" as Stack
import "js/MediaPlayerHelper.js" as Helper


Page {
    id: player

    property variant model
    property int index
    property bool upnp
    property variant mediaPlayer: global.audioVideoPlayer

    function systemsButtonClicked() {
        Stack.backToMultimedia()
    }

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
        color: "gray"
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
            largeInterval: 500
            smallInterval: 350

            onClicked: {
                if (repetitionTriggered) {
                    player.mediaPlayer.seek(-10)
                }
                else
                    player.mediaPlayer.prevTrack()
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
                Stack.backToMultimedia()
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
            largeInterval: 500
            smallInterval: 350

            onClicked: {
                // seek enabled only for audio
                if (repetitionTriggered) {
                    player.mediaPlayer.seek(10)
                }
                else
                    player.mediaPlayer.nextTrack()
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

        onClicked: Stack.goToPage('Devices.qml', {restoreBrowserState: true})
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
            if (info["meta_title"] && info["meta_artist"])
                return info["meta_title"] + " - " + info["meta_artist"]
            else if (info["meta_title"])
                return info["meta_title"]
            else if (info["file_name"])
                return info["file_name"]
            else return ""
        }
    }

    Component.onCompleted: Helper.initAudioPlayer(mediaPlayer, model, upnp, index)
}
