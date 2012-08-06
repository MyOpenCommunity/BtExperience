import QtQuick 1.1
import Components 1.0


Page {
    id: player

    property variant model
    property variant item

    source: "images/multimedia.jpg"
    showSystemsButton: true

    SvgImage {
        id: frameBg

        source: "images/common/bordo_finestra.svg"
        anchors {
            top: player.toolbar.bottom
            topMargin: 15
            horizontalCenter: parent.horizontalCenter
            horizontalCenterOffset: player.navigationBar.width / 2
        }
    }

    SvgImage {
        id: frame

        source: "images/common/finestra.svg"
        anchors.centerIn: frameBg
    }

    Rectangle {
        id: fullScreenBg

        color: "black"
        visible: false
        anchors {
            top: player.toolbar.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
    }

    SvgImage {
        id: thePhoto

        source: item.path
        fillMode: Image.PreserveAspectFit
        anchors.fill: frame
    }

    SvgImage {
        id: bottomBarBg

        source: "images/common/bg_player.svg"
        anchors {
            top: frameBg.bottom
            topMargin: 10
            horizontalCenter: frameBg.horizontalCenter
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
            verticalCenter: bottomBarBg.verticalCenter
            left: bottomBarBg.left
            leftMargin: 17
        }

        onClicked: console.log("previous photo")
        status: 0
    }

    ButtonImageThreeStates {
        id: playButton

        defaultImageBg: "images/common/btn_play_pause.svg"
        pressedImageBg: "images/common/btn_play_pause_P.svg"
        shadowImage: "images/common/ombra_btn_play_pause.svg"
        defaultImage: "images/common/ico_play.svg"
        pressedImage: "images/common/ico_play_P.svg"
        anchors {
            verticalCenter: bottomBarBg.verticalCenter
            left: prevButton.right
            leftMargin: 4
        }

        onClicked: console.log("play photo")
        status: 0
    }

    ButtonImageThreeStates {
        id: nextButton

        defaultImageBg: "images/common/btn_player_comando.svg"
        pressedImageBg: "images/common/btn_player_comando_P.svg"
        shadowImage: "images/common/ombra_btn_player_comando.svg"
        defaultImage: "images/common/ico_next_track.svg"
        pressedImage: "images/common/ico_next_track_P.svg"
        anchors {
            verticalCenter: bottomBarBg.verticalCenter
            left: playButton.right
            leftMargin: 4
        }

        onClicked: console.log("next photo")
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
            verticalCenter: bottomBarBg.verticalCenter
            left: nextButton.right
            leftMargin: 13
        }

        onClicked: console.log("folder photo")
        status: 0
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
        anchors {
            verticalCenter: bottomBarBg.verticalCenter
            right: bottomBarBg.right
            rightMargin: 17
        }

        onClicked: {
            console.log("full screen photo")
            if (player.state === "")
                player.state = "fullscreen"
            else
                player.state = ""
        }
        status: 0
    }

    states: [
        State {
            name: "fullscreen"
            PropertyChanges { target: fullScreenBg; visible: true }
            PropertyChanges { target: fullScreenToggle; status: 1 }
            PropertyChanges {
                target: bottomBarBg
                source: "images/common/bg_player_fullscreen.svg"
                anchors.topMargin: 0
            }
            AnchorChanges {
                target: bottomBarBg
                anchors.top:undefined
                anchors.bottom: fullScreenBg.bottom
                anchors.horizontalCenter: fullScreenBg.horizontalCenter
            }
            PropertyChanges {
                target: thePhoto
                anchors.fill: fullScreenBg
            }
        }
    ]
}
