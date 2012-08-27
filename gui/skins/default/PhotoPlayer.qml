import QtQuick 1.1
import Components 1.0

import "js/Stack.js" as Stack


Page {
    id: player

    property variant model
    property int index

    source: "images/multimedia.jpg"
    showSystemsButton: true
    text: qsTr("Photo")

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
        opacity: 0
        anchors {
            top: player.toolbar.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
    }

    SvgImage {
        id: thePhoto

        source: global.photoPlayer.fileName
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

        onClicked: global.photoPlayer.prevPhoto()
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
            verticalCenter: bottomBarBg.verticalCenter
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
                if (playButtonItem.state === "")
                    playButtonItem.state = "slideshow"
                else
                    playButtonItem.state = ""
            }

            status: 0

            Timer {
                id: slideshowTimer

                interval: 4000 // TODO where to take this value?
                running: false
                repeat: true
                onTriggered: global.photoPlayer.nextPhoto()
            }
        }

        states: [
            State {
                name: "slideshow"
                PropertyChanges {
                    target: slideshowTimer
                    running: true
                }
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
            verticalCenter: bottomBarBg.verticalCenter
            left: playButtonItem.right
            leftMargin: 4
        }

        onClicked: global.photoPlayer.nextPhoto()

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

        onClicked: Stack.popPage()
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
            if (player.state === "")
                player.state = "fullscreen"
            else
                player.state = ""
        }
        status: 0
    }

    function backButtonClicked() {
        Stack.popPages(2)
    }

    Component.onCompleted: global.photoPlayer.generatePlaylist(player.model, player.index, player.model.count)

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
