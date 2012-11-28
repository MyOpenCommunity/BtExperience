import QtQuick 1.1
import BtObjects 1.0
import BtExperience 1.0
import Components 1.0
import Components.Text 1.0

import "js/Stack.js" as Stack


Page {
    id: player

    property variant model
    property int index
    property bool isVideo: true
    property bool upnp
    property variant mediaPlayer: global.audioVideoPlayer

    source: "images/multimedia.jpg"
    showSystemsButton: true
    text: player.isVideo ? qsTr("Video") : qsTr("Audio")

    function systemsButtonClicked() {
        Stack.backToMultimedia()
    }

    SvgImage {
        id: frameBg

        property int innerBorder: 7
        property int innerX: x + innerBorder
        property int innerY: y + innerBorder
        property int innerWidth: width - 2 *innerBorder
        property int innerHeight: height - 2 *innerBorder

        source: "images/common/video_player_bg_frame.svg"
        visible: player.isVideo
        anchors {
            top: player.toolbar.bottom
            topMargin: frameBg.height / 100 * 3.89
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
            topMargin: frameBg.height / 100 * 2.59
            horizontalCenter: frameBg.horizontalCenter
        }
    }

    UbuntuLightText {
        id: title

        text: player.mediaPlayer.trackName
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

            defaultImageBg: "images/common/btn_player_comando.svg"
            pressedImageBg: "images/common/btn_player_comando_P.svg"
            shadowImage: "images/common/ombra_btn_player_comando.svg"
            defaultImage: "images/common/ico_previous_track.svg"
            pressedImage: "images/common/ico_previous_track_P.svg"
            repetitionOnHold: player.isVideo ? false : true
            largeInterval: 500
            smallInterval: 350

            onClicked: {
                if (repetitionTriggered && !player.isVideo) {
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

                defaultImageBg: player.isVideo ? "images/common/btn_play_pause.svg" : "images/common/btn_player_comando.svg"
                pressedImageBg: player.isVideo ? "images/common/btn_play_pause_P.svg" : "images/common/btn_player_comando_P.svg"
                shadowImage: player.isVideo ? "images/common/ombra_btn_play_pause.svg" : "images/common/ombra_btn_player_comando.svg"
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
            visible: !player.isVideo

            defaultImageBg: "images/common/btn_player_comando.svg"
            pressedImageBg: "images/common/btn_player_comando_P.svg"
            shadowImage: "images/common/ombra_btn_player_comando.svg"
            defaultImage: "images/common/ico_stop.svg"
            pressedImage: "images/common/ico_stop_P.svg"

            onClicked: {
                player.mediaPlayer.terminate()
                Stack.backToMultimedia()
            }
        }

        ButtonImageThreeStates {
            id: nextButton

            defaultImageBg: "images/common/btn_player_comando.svg"
            pressedImageBg: "images/common/btn_player_comando_P.svg"
            shadowImage: "images/common/ombra_btn_player_comando.svg"
            defaultImage: "images/common/ico_next_track.svg"
            pressedImage: "images/common/ico_next_track_P.svg"
            repetitionOnHold: player.isVideo ? false : true
            largeInterval: 500
            smallInterval: 350

            onClicked: {
                // seek enabled only for audio
                if (repetitionTriggered && !player.isVideo) {
                    player.mediaPlayer.seek(10)
                }
                else
                    player.mediaPlayer.nextTrack()
            }
        }
    }

    ButtonImageThreeStates {
        id: folderButton

        defaultImageBg: "images/common/btn_player_comando.svg"
        pressedImageBg: "images/common/btn_player_comando_P.svg"
        shadowImage: "images/common/ombra_btn_player_comando.svg"
        defaultImage: "images/common/ico_browse.svg"
        pressedImage: "images/common/ico_browse_P.svg"
        anchors {
            top: playerControl.top
            left: playerControl.right
            leftMargin: frameBg.width / 100 * 1.90
        }

        onClicked: Stack.backToPage("Devices.qml")
    }

    Item {
        // I used an Item to define some specific states for the buttonMute
        // please note that buttonMute is a ButtonImageThreeStates so it defines
        // its internal states, it is neither possible nor desirable to redefine
        // these internal states
        id: buttonMuteItem

        width: buttonMute.width
        height: buttonMute.height

        anchors {
            top: playerControl.top
            right: buttonMinus.left
            rightMargin: frameBg.width / 100 * 1.90
        }

        ButtonImageThreeStates {
            id: buttonMute

            defaultImageBg: "images/common/btn_player_comando.svg"
            pressedImageBg: "images/common/btn_player_comando_P.svg"
            shadowImage: "images/common/ombra_btn_mute.svg"
            defaultImage: "images/common/ico_mute.svg"
            pressedImage: "images/common/ico_mute.svg"
            anchors.centerIn: parent

            onClicked: player.mediaPlayer.mute = !player.mediaPlayer.mute
        }

        state: player.mediaPlayer.mute ? "mute" : ""

        states: [
            State {
                name: "mute"
                PropertyChanges {
                    target: buttonMute
                    defaultImage: "images/common/ico_mute_on.svg"
                    pressedImage: "images/common/ico_mute_on.svg"
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
        onClicked: player.mediaPlayer.decrementVolume()
        repetitionOnHold: true
        anchors {
            top: playerControl.top
            right: buttonPlus.left
            rightMargin: frameBg.width / 100 * 0.58
        }
    }

    ButtonImageThreeStates {
        id: buttonPlus
        defaultImageBg: "images/common/btn_player_comando.svg"
        pressedImageBg: "images/common/btn_player_comando_P.svg"
        shadowImage: "images/common/ombra_btn_piu_meno.svg"
        defaultImage: "images/common/ico_piu.svg"
        pressedImage: "images/common/ico_piu_P.svg"
        onClicked: player.mediaPlayer.incrementVolume()
        repetitionOnHold: true
        anchors {
            top: playerControl.top
            right: player.isVideo ? fullScreenToggle.left : bottomBarBg.right
            rightMargin: player.isVideo ? frameBg.width / 100 * 1.90 : frameBg.width / 100 * 2.48
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
            top: playerControl.top
            right: bottomBarBg.right
            rightMargin: frameBg.width / 100 * 2.48
        }

        onClicked: {
            if (player.state === "")
                player.state = "fullscreen"
            else
                player.state = ""
        }
    }

    SvgImage {
        id: volumePopup

        source: "images/common/regola_volume/bg_regola_volume.svg"
        opacity: 0
        anchors {
            bottom: bottomBarBg.top
            bottomMargin: frameBg.height / 100 * 2.85
            right: bottomBarBg.right
        }

        UbuntuLightText {
            text: qsTr("mute")
            color: "white"
            font.pixelSize: frameBg.height / 100 * 3.63
            font.capitalization: Font.AllUppercase
            anchors {
                top: volumePopup.top
                topMargin: frameBg.height / 100 * 1.81
                left: volumePopup.left
                leftMargin: frameBg.width / 100 * 2.48
            }
        }

        UbuntuLightText {
            text: player.mediaPlayer.volume
            color: "white"
            font.pixelSize: frameBg.height / 100 * 3.63
            anchors {
                top: volumePopup.top
                topMargin: frameBg.height / 100 * 1.81
                right: volumePopup.right
                rightMargin: frameBg.width / 100 * 2.48
            }
        }

        SvgImage {
            id: muteIcon

            source: player.mediaPlayer.mute ? "images/common/regola_volume/ico_mute.svg" : "images/common/regola_volume/ico_volume.svg"
            anchors {
                top: volumePopup.top
                topMargin: frameBg.height / 100 * 9.33
                left: volumePopup.left
                leftMargin: frameBg.width / 100 * 2.48
            }
        }

        SvgImage {
            source: "images/common/regola_volume/bg_volume.svg"
            anchors {
                verticalCenter: muteIcon.verticalCenter
                left: muteIcon.right
                leftMargin: frameBg.width / 100 * 0.58
            }

            Rectangle {
                height: parent.height + 2
                width: parent.width * (player.mediaPlayer.volume < 1 ? 1 : player.mediaPlayer.volume) / 100 + 4
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
            target: player.mediaPlayer
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
        Stack.backToMultimedia()
    }

    Component.onCompleted: player._initMediaPlayer()
    Component.onDestruction: {
        if (player.isVideo) {
            player.mediaPlayer.terminate()
            player.mediaPlayer.mute = false
        }
    }

    function _initMediaPlayer() {
        // an helper variable for readability
        var p = player

        p.mediaPlayer.videoRect = Qt.rect(frameBg.innerX, frameBg.innerY, frameBg.innerWidth, frameBg.innerHeight)

        // if player.model is set assumes a new playlist must be set
        if (p.model) {
            if (p.upnp)
                p.mediaPlayer.generatePlaylistUPnP(p.model, p.index, p.model.count, p.isVideo)
            else
                p.mediaPlayer.generatePlaylistLocal(p.model, p.index, p.model.count, p.isVideo)
            return
        }

        // player.model is not set, checks if playlist is set
        if (p.mediaPlayer.playing)
            return // everything is fine

        // we don't have a model and we don't have a playlist: something is wrong somewhere...
        console.log("Impossible to init MediaPlayer in QML: no model and no playlist to play")
    }

    states: [
        State {
            name: ""
            PropertyChanges {
                target: mediaPlayer
                videoRect: Qt.rect(frameBg.innerX, frameBg.innerY, frameBg.innerWidth, frameBg.innerHeight)
            }
        },
        State {
            name: "fullscreen"
            PropertyChanges { target: fullScreenBg; opacity: 1 }
            PropertyChanges { target: fullScreenToggle; status: 1 }
            PropertyChanges {
                target: mediaPlayer
                videoRect: Qt.rect(fullScreenBg.x, fullScreenBg.y,
                                   fullScreenBg.width, fullScreenBg.height - player.toolbar.height)
            }
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
                anchors.leftMargin: frameBg.width / 100 * 3.80
                anchors.rightMargin: frameBg.width / 100 * 18.69
            }
            AnchorChanges {
                target: imageSlider
                anchors.top: undefined
                anchors.horizontalCenter: undefined
                anchors.verticalCenter: playerControl.verticalCenter
                anchors.left: folderButton.right
                anchors.right: buttonMuteItem.left
            }
            AnchorChanges {
                target: playerControl
                anchors.top: bottomBarBg.top
            }
            PropertyChanges {
                target: title
                visible: false
            }
            PropertyChanges {
                target: duration
                anchors.topMargin: 0
                anchors.rightMargin: 0
                anchors.leftMargin: frameBg.width / 100 * 1.02
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
                PropertyAnimation {
                    target: mediaPlayer
                    property: "videoRect"
                    duration: 400
                }
                AnchorAnimation {
                    duration: 400
                }
            }
        }
    ]

    Connections {
        target: mediaPlayer
        onVolumeChanged: {
            global.audioState.setVolume(mediaPlayer.volume)
        }
        onMuteChanged: {
            if (mediaPlayer.mute)
                global.audioState.enableState(AudioState.LocalPlaybackMute)
            else
                global.audioState.disableState(AudioState.LocalPlaybackMute)
        }
    }
}
