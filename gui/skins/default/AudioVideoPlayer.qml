import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Text 1.0

import "js/Stack.js" as Stack


Page {
    id: player

    property variant model
    property int index
    property bool isVideo: true

    source: "images/multimedia.jpg"
    showSystemsButton: true
    text: player.isVideo ? qsTr("Video") : qsTr("Audio")

    SvgImage {
        id: frameBg

        source: "images/common/video_player_bg_frame.svg"
        visible: player.isVideo
        anchors {
            top: player.toolbar.bottom
            topMargin: 15
            horizontalCenter: parent.horizontalCenter
            horizontalCenterOffset: player.navigationBar.width / 2
        }
    }

    SvgImage {
        id: frame

        source: "images/common/video_player_frame.svg"
        visible: player.isVideo
        anchors.centerIn: frameBg
    }

    Rectangle {
        id: fullScreenBg

        color: "black"
        opacity: 0
        anchors {
            top: player.toolbar.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
    }

    SvgImage {
        id: bottomBarBg

        source: "images/common/video_player_bg_box.svg"
        anchors {
            top: frameBg.bottom
            topMargin: 10
            horizontalCenter: frameBg.horizontalCenter
        }
    }

    UbuntuLightText {
        id: title

        text: global.audioVideoPlayer.trackName
        color: "white"
        font.pixelSize: 14
        anchors {
            top: bottomBarBg.top
            topMargin: 7
            left: bottomBarBg.left
            leftMargin: 17
        }
    }

    UbuntuLightText {
        id: duration

        text: global.audioVideoPlayer.currentTime + " / " + global.audioVideoPlayer.totalTime
        color: "gray"
        horizontalAlignment: Text.AlignRight
        font.pixelSize: 14
        anchors {
            top: bottomBarBg.top
            topMargin: 7
            right: bottomBarBg.right
            rightMargin: 17
        }
    }

    SvgImage {
        id: imageSlider

        source: "images/common/bg_tempo.svg"
        anchors {
            top: bottomBarBg.top
            topMargin: 32
            horizontalCenter: bottomBarBg.horizontalCenter
        }

        Rectangle {
            height: imageSlider.height + 2
            width: imageSlider.width * (global.audioVideoPlayer.percentage < 1 ? 1 : global.audioVideoPlayer.percentage) / 100 + 4
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

    ButtonImageThreeStates {
        id: prevButton

        defaultImageBg: "images/common/btn_player_comando.svg"
        pressedImageBg: "images/common/btn_player_comando_P.svg"
        shadowImage: "images/common/ombra_btn_player_comando.svg"
        defaultImage: "images/common/ico_previous_track.svg"
        pressedImage: "images/common/ico_previous_track_P.svg"
        anchors {
            top: imageSlider.bottom
            topMargin: 7
            left: bottomBarBg.left
            leftMargin: 17
        }

        onClicked: global.audioVideoPlayer.prevTrack()
        status: 0
    }

    Item {
        // I used an Item to define some specific states for the playButton
        // please note that playButton is a ButtonImageThreeStates so it defines
        // its internal states, it is neither possible nor desirable to redefine
        // these internal states
        id: playButtonItem

        width: playButton.width
        height: playButton.height

        anchors {
            top: prevButton.top
            left: prevButton.right
            leftMargin: 4
        }

        ButtonImageThreeStates {
            id: playButton

            defaultImageBg: "images/common/btn_play_pause.svg"
            pressedImageBg: "images/common/btn_play_pause_P.svg"
            shadowImage: "images/common/ombra_btn_play_pause.svg"
            defaultImage: "images/common/ico_play.svg"
            pressedImage: "images/common/ico_play_P.svg"
            anchors.centerIn: parent

            onClicked: {
                if (playButtonItem.state === "") {
                    playButtonItem.state = "play"
                    global.audioVideoPlayer.mediaPlayer.resume()
                }
                else {
                    playButtonItem.state = ""
                    global.audioVideoPlayer.mediaPlayer.pause()
                }
            }

            status: 0
        }

        state: "play"

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
        id: nextButton

        defaultImageBg: "images/common/btn_player_comando.svg"
        pressedImageBg: "images/common/btn_player_comando_P.svg"
        shadowImage: "images/common/ombra_btn_player_comando.svg"
        defaultImage: "images/common/ico_next_track.svg"
        pressedImage: "images/common/ico_next_track_P.svg"
        anchors {
            top: prevButton.top
            left: playButtonItem.right
            leftMargin: 4
        }

        onClicked: global.audioVideoPlayer.nextTrack()

        status: 0
    }

    ButtonImageThreeStates {
        id: folderButton

        defaultImageBg: "images/common/btn_player_comando.svg"
        pressedImageBg: "images/common/btn_player_comando_P.svg"
        shadowImage: "images/common/ombra_btn_player_comando.svg"
        defaultImage: "images/common/ico_browse.svg"
        pressedImage: "images/common/ico_browse_P.svg"
        anchors {
            top: prevButton.top
            left: nextButton.right
            leftMargin: 13
        }

        onClicked: Stack.popPage()
        status: 0
    }

    ButtonImageThreeStates {
        id: buttonMute
        defaultImageBg: "images/common/btn_player_comando.svg"
        pressedImageBg: "images/common/btn_player_comando_P.svg"
        shadowImage: "images/common/ombra_btn_mute.svg"
        defaultImage: "images/common/ico_mute.svg"
        pressedImage: "images/common/ico_mute.svg"
        onClicked: global.audioVideoPlayer.mute = !global.audioVideoPlayer.mute
        status: 0
        anchors {
            top: prevButton.top
            right: buttonMinus.left
            rightMargin: 13
        }
        state: global.audioVideoPlayer.mute ? "mute" : ""

        states: [
            State {
                name: "mute"
                PropertyChanges {
                    target: buttonMute
                    defaultImage: "images/common/ico_mute_on.svg"
                    pressedImage: "images/common/ico_mute_on.svg"
                    status: 0
                }
            }
        ]
    }

    ButtonImageThreeStates {
        id: buttonMinus
        defaultImageBg: "images/common/btn_player_comando.svg"
        pressedImageBg: "images/common/btn_player_comando_P.svg"
        shadowImage: "images/common/ombra_btn_piu_meno.svg"
        defaultImage: "images/common/ico_meno.svg"
        pressedImage: "images/common/ico_meno_P.svg"
        onClicked: global.audioVideoPlayer.decrementVolume()
        status: 0
        repetitionOnHold: true
        anchors {
            top: prevButton.top
            right: buttonPlus.left
            rightMargin: 4
        }
    }

    ButtonImageThreeStates {
        id: buttonPlus
        defaultImageBg: "images/common/btn_player_comando.svg"
        pressedImageBg: "images/common/btn_player_comando_P.svg"
        shadowImage: "images/common/ombra_btn_piu_meno.svg"
        defaultImage: "images/common/ico_piu.svg"
        pressedImage: "images/common/ico_piu_P.svg"
        onClicked: global.audioVideoPlayer.incrementVolume()
        status: 0
        repetitionOnHold: true
        anchors {
            top: prevButton.top
            right: player.isVideo ? fullScreenToggle.left : bottomBarBg.right
            rightMargin: player.isVideo ? 13 : 17
        }
    }

    ButtonImageThreeStates {
        id: fullScreenToggle

        defaultImageBg: "images/common/btn_player_comando.svg"
        pressedImageBg: "images/common/btn_player_comando_P.svg"
        selectedImageBg: "images/common/btn_player_comando_S.svg"
        shadowImage: "images/common/ombra_btn_player_comando.svg"
        defaultImage: "images/common/ico_fullscreen.svg"
        pressedImage: "images/common/ico_fullscreen.svg"
        selectedImage: "images/common/ico_chiudi_fullscreen.svg"
        visible: player.isVideo
        anchors {
            top: prevButton.top
            right: bottomBarBg.right
            rightMargin: 17
        }

        onClicked: {
            if (player.state === "")
                player.state = "fullscreen"
            else
                player.state = ""
        }
        status: 0
    }

    SvgImage {
        id: volumePopup

        source: "images/common/regola_volume/bg_regola_volume.svg"
        opacity: 0
        anchors {
            bottom: bottomBarBg.top
            bottomMargin: 11
            right: bottomBarBg.right
        }

        UbuntuLightText {
            text: qsTr("mute")
            color: "white"
            font.pixelSize: 14
            font.capitalization: Font.AllUppercase
            anchors {
                top: volumePopup.top
                topMargin: 7
                left: volumePopup.left
                leftMargin: 17
            }
        }

        UbuntuLightText {
            text: global.audioVideoPlayer.volume
            color: "white"
            font.pixelSize: 14
            anchors {
                top: volumePopup.top
                topMargin: 7
                right: volumePopup.right
                rightMargin: 17
            }
        }

        SvgImage {
            id: muteIcon

            source: global.audioVideoPlayer.mute ? "images/common/regola_volume/ico_mute.svg" : "images/common/regola_volume/ico_volume.svg"
            anchors {
                top: volumePopup.top
                topMargin: 36
                left: volumePopup.left
                leftMargin: 17
            }
        }

        SvgImage {
            source: "images/common/regola_volume/bg_volume.svg"
            anchors {
                verticalCenter: muteIcon.verticalCenter
                left: muteIcon.right
                leftMargin: 4
            }

            Rectangle {
                height: parent.height + 2
                width: parent.width * (global.audioVideoPlayer.volume < 1 ? 1 : global.audioVideoPlayer.volume) / 100 + 4
                radius: 100
                smooth: true
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
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

        Timer {
            id: hidingTimer

            interval: 2000
            onTriggered: volumePopup.state = ""
        }

        Connections {
            target: global.audioVideoPlayer
            onVolumeChanged: {
                volumePopup.state = "volumeChanged"
                hidingTimer.restart() // don't use start or popup will blink when pressedAndHold
            }
            onMuteChanged: {
                volumePopup.state = "volumeChanged"
                hidingTimer.restart() // don't use start or popup will blink when pressedAndHold
            }
        }

        states: [
            State {
                name: "volumeChanged"
                PropertyChanges { target: volumePopup; opacity: 1 }
            }
        ]

        transitions: [
            Transition {
                NumberAnimation {
                    target: volumePopup
                    property: "opacity"
                    duration: 400
                }
            }
        ]
    }

    function backButtonClicked() {
        Stack.popPages(2)
    }

    Component.onCompleted: global.audioVideoPlayer.generatePlaylist(player.model, player.index, player.model.count)
    Component.onDestruction: if (player.isVideo) global.audioVideoPlayer.terminate()

    states: [
        State {
            name: "fullscreen"
            PropertyChanges { target: fullScreenBg; opacity: 1 }
            PropertyChanges { target: fullScreenToggle; status: 1 }
            PropertyChanges {
                target: bottomBarBg
                source: "images/common/bg_player_fullscreen.svg"
                anchors.topMargin: 0
            }
            AnchorChanges {
                target: bottomBarBg
                anchors.top: undefined
                anchors.bottom: fullScreenBg.bottom
                anchors.horizontalCenter: fullScreenBg.horizontalCenter
            }
            PropertyChanges {
                target: imageSlider
                source: "images/common/bg_tempo_fullscreen.svg"
                anchors.topMargin: 0
                anchors.leftMargin: 26
                anchors.rightMargin: 128
            }
            AnchorChanges {
                target: imageSlider
                anchors.top: undefined
                anchors.horizontalCenter: undefined
                anchors.verticalCenter: prevButton.verticalCenter
                anchors.left: folderButton.right
                anchors.right: buttonMute.left
            }
            AnchorChanges {
                target: prevButton
                anchors.top: bottomBarBg.top
            }
            PropertyChanges {
                target: theVideo
                anchors.fill: fullScreenBg
            }
            PropertyChanges {
                target: title
                visible: false
            }
            PropertyChanges {
                target: duration
                anchors.topMargin: 0
                anchors.rightMargin: 0
                anchors.leftMargin: 7
            }
            AnchorChanges {
                target: duration
                anchors.top: undefined
                anchors.right: undefined
                anchors.left: imageSlider.right
                anchors.verticalCenter: imageSlider.verticalCenter
            }
        }
    ]

    transitions: [
        Transition {
            ParallelAnimation {
                NumberAnimation {
                    target: fullScreenBg
                    property: "opacity"
                    duration: 400
                }
                AnchorAnimation {
                    duration: 400
                }
            }
        }
    ]
}
