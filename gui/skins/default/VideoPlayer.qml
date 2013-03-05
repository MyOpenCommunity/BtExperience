import QtQuick 1.1
import BtExperience 1.0
import Components 1.0
import Components.Text 1.0
import Components.SoundDiffusion 1.0
import Components.Popup 1.0

import "js/Stack.js" as Stack
import "js/MediaPlayerHelper.js" as Helper

BasePage {
    id: page

    property QtObject player: global.audioVideoPlayer
    property variant model
    property int index
    property bool upnp

    Rectangle {
        id: fullScreenBg

        color: "#010203"
        anchors.fill: parent

        MouseArea {
            anchors.fill: parent
            onPressed: {
                hidingTimer.stop()
                bottomBarBg.visible = true
            }
            onReleased: hidingTimer.restart()
        }
    }

    SvgImage {
        id: bottomBarBg

        source: "images/common/bg_player_fullscreen.svg"
        anchors {
            horizontalCenter: fullScreenBg.horizontalCenter
            bottom: fullScreenBg.bottom
        }

        Row {
            id: playerControl
            spacing: page.width / 100 * 0.50
            anchors {
                top: bottomBarBg.top
                topMargin: page.height / 100 * 1.2
                left: bottomBarBg.left
                leftMargin: page.width / 100 * 1.65
            }

            ButtonImageThreeStates {
                id: prevButton

                defaultImageBg: "images/common/btn_45x35.svg"
                pressedImageBg: "images/common/btn_45x35_P.svg"
                shadowImage: "images/common/btn_shadow_45x35.svg"
                defaultImage: "images/common/ico_previous_track.svg"
                pressedImage: "images/common/ico_previous_track_P.svg"

                onReleased: hidingTimer.restart()
                onPressed: {
                    if (goToPrevTrack.running) {
                        goToPrevTrack.restart()
                        page.player.prevTrack()
                    } else {
                        goToPrevTrack.start()
                        page.player.restart()
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

                    defaultImageBg: "images/common/btn_99x35.svg"
                    pressedImageBg: "images/common/btn_99x35_P.svg"
                    shadowImage: "images/common/btn_shadow_99x35.svg"
                    defaultImage: "images/common/ico_play.svg"
                    pressedImage: "images/common/ico_play_P.svg"
                    anchors.centerIn: parent

                    onReleased: hidingTimer.restart()
                    onPressed: {
                        if (page.player.playing)
                            page.player.pause()
                        else
                            page.player.resume()
                    }
                }

                state: page.player.playing ? "play" : ""

                states: [
                    State {
                        name: "play"
                        PropertyChanges {
                            target: playButton
                            defaultImage: "images/common/ico_pause.svg"
                            pressedImage: "images/common/ico_pause_P.svg"
                        }
                        PropertyChanges { target: forceScreenOn; enabled: true }
                    }
                ]
            }

            ScreenStateHandler {
                id: forceScreenOn
            }

            ButtonImageThreeStates {
                id: nextButton

                defaultImageBg: "images/common/btn_45x35.svg"
                pressedImageBg: "images/common/btn_45x35_P.svg"
                shadowImage: "images/common/btn_shadow_45x35.svg"
                defaultImage: "images/common/ico_next_track.svg"
                pressedImage: "images/common/ico_next_track_P.svg"

                onReleased: hidingTimer.restart()
                onPressed: page.player.nextTrack()
            }
        }

        SvgImage {
            id: imageSlider

            source: "images/common/bg_tempo_fullscreen.svg"
            anchors {
                left: playerControl.right
                leftMargin: page.width / 100 * 2.6
                right: controlAudio.left
                rightMargin: page.width / 100 * 12.5
                verticalCenter: playerControl.verticalCenter
            }

            Rectangle {
                height: imageSlider.height + 2
                width: imageSlider.width * (page.player.percentage < 1 ? 1 : page.player.percentage) / 100 + 4
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

        UbuntuLightText {
            id: time

            text: page.player.currentTime + " / " + page.player.totalTime
            color: "#323232"
            horizontalAlignment: Text.AlignRight
            font.pixelSize: page.height / 100 * 2.4
            anchors {
                left: imageSlider.right
                leftMargin: page.width / 100 * 0.5
                verticalCenter: imageSlider.verticalCenter
            }
        }

        ControlAudio {
            id: controlAudio
            anchors {
                top: playerControl.top
                right: fullScreenToggle.left
                rightMargin: page.width / 100 * 1.1
            }

            isPlayerMute: page.player.mute
            onMuteClicked: page.player.mute = !page.player.mute
            onDecrementVolume: page.player.decrementVolume()
            onIncrementVolume: page.player.incrementVolume()
        }

        ButtonImageThreeStates {
            id: fullScreenToggle

            anchors {
                top: playerControl.top
                right: bottomBarBg.right
                rightMargin: page.width / 100 * 1.65
            }

            defaultImageBg: "images/common/btn_45x35.svg"
            pressedImageBg: "images/common/btn_45x35_P.svg"
            selectedImageBg: "images/common/btn_45x35_S.svg"
            shadowImage: "images/common/btn_shadow_45x35.svg"
            defaultImage: "images/common/icon_resize.svg"
            pressedImage: "images/common/icon_resize_p.svg"

            onPressed: Stack.popPage()
        }

        Timer {
            id: hidingTimer
            interval: 5000
            running: true
            onTriggered: {
                bottomBarBg.visible = false
            }
        }

        MouseArea {
            anchors.fill: parent
            onPressed: {
                // setting accepted property to false causes released event
                // to be discarded, so we have to call restart in buttons on top
                // of this MouseArea
                mouse.accepted = false
                hidingTimer.stop()
            }
        }
    }

    VolumePopup {
        volume: page.player.volume
        mute: page.player.mute
        anchors {
            bottom: bottomBarBg.top
            bottomMargin: page.height / 100 * 1
            right: bottomBarBg.right
        }
    }

    Component {
        id: errorFeedback
        FeedbackPopup {
            text: ""
            isOk: false
        }
    }

    Connections {
        target: page.player
        onVolumeChanged: {
            global.audioState.setVolume(AudioState.LocalPlaybackVolume, page.player.volume)
        }
        onMuteChanged: {
            if (page.player.mute)
                global.audioState.enableState(AudioState.LocalPlaybackMute)
            else
                global.audioState.disableState(AudioState.LocalPlaybackMute)
        }
        onLoopDetected: {
            var props = {text: qsTr("Loop detected")}

            page.installPopup(errorFeedback, props)
        }
    }

    Component.onCompleted: {
        player.videoRect = Qt.rect(0, 0, 1024, 600)
        Helper.initVideoPlayer(player, model, upnp, index)
    }
    Component.onDestruction: {
        player.terminate()
        player.mute = false
    }
}
