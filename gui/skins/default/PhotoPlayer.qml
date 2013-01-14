import QtQuick 1.1
import Components 1.0

import "js/Stack.js" as Stack


Page {
    id: player

    property variant model
    property int index
    property bool upnp

    source: "images/background/multimedia.jpg"
    showSystemsButton: true
    text: qsTr("Photo")

    SvgImage {
        id: frameBg

        source: "images/common/bordo_finestra.svg"
        anchors {
            top: player.toolbar.bottom
            topMargin: frameBg.height / 100 * 3.67
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
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        MouseArea {
            anchors.fill: parent
            onPressed: {
                bottomBarBg.visible = true
                bottomBarBg.restartAutoHide()
            }
        }
    }

    Image {
        id: thePhoto

        source: global.photoPlayer.fileName
        sourceSize: Qt.size(frame.width, frame.height)
        fillMode: Image.PreserveAspectFit
        anchors.fill: frame
        cache: false
    }

    SvgImage {
        id: bottomBarBg

        property bool enableAutoHide: player.state === "fullscreen"

        function restartAutoHide() {
            hidingTimer.restart()
        }

        source: "images/common/bg_player.svg"
        anchors {
            top: frameBg.bottom
            topMargin: frameBg.height / 100 * 2.44
            horizontalCenter: frameBg.horizontalCenter
        }

        ButtonImageThreeStates {
            id: prevButton

            defaultImageBg: "images/common/btn_45x35.svg"
            pressedImageBg: "images/common/btn_45x35_P.svg"
            shadowImage: "images/common/btn_shadow_45x35.svg"
            defaultImage: "images/common/ico_previous_track.svg"
            pressedImage: "images/common/ico_previous_track_P.svg"
            anchors {
                verticalCenter: bottomBarBg.verticalCenter
                left: bottomBarBg.left
                leftMargin: frameBg.height / 100 * 2.81
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
                leftMargin: frameBg.height / 100 * 0.67
            }

            ButtonImageThreeStates {
                id: playButton

                defaultImageBg: "images/common/btn_99x35.svg"
                pressedImageBg: "images/common/btn_99x35_P.svg"
                shadowImage: "images/common/btn_shadow_99x35.svg"
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

                    interval: 10000 // TODO where to take this value?
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
                    PropertyChanges { target: forceScreenOn; enabled: true }
                }
            ]
        }

        ButtonImageThreeStates {
            id: nextButton

            defaultImageBg: "images/common/btn_45x35.svg"
            pressedImageBg: "images/common/btn_45x35_P.svg"
            shadowImage: "images/common/btn_shadow_45x35.svg"
            defaultImage: "images/common/ico_next_track.svg"
            pressedImage: "images/common/ico_next_track_P.svg"
            anchors {
                verticalCenter: bottomBarBg.verticalCenter
                left: playButtonItem.right
                leftMargin: frameBg.height / 100 * 0.67
            }

            onClicked: global.photoPlayer.nextPhoto()

            status: 0
        }

        ButtonImageThreeStates {
            id: folderButton

            defaultImageBg: "images/common/btn_45x35.svg"
            pressedImageBg: "images/common/btn_45x35_P.svg"
            shadowImage: "images/common/btn_shadow_45x35.svg"
            defaultImage: "images/common/ico_browse.svg"
            pressedImage: "images/common/ico_browse_P.svg"
            anchors {
                verticalCenter: bottomBarBg.verticalCenter
                left: nextButton.right
                leftMargin: frameBg.height / 100 * 2.15
            }

            onClicked: Stack.backToPage("Devices.qml")
            status: 0
        }

        ButtonImageThreeStates {
            id: fullScreenToggle

            defaultImageBg: "images/common/btn_45x35.svg"
            pressedImageBg: "images/common/btn_45x35_P.svg"
            selectedImageBg: "images/common/btn_45x35_S.svg"
            shadowImage: "images/common/btn_shadow_45x35.svg"
            defaultImage: "images/common/ico_fullscreen.svg"
            pressedImage: "images/common/ico_fullscreen.svg"
            selectedImage: "images/common/ico_chiudi_fullscreen.svg"
            anchors {
                verticalCenter: bottomBarBg.verticalCenter
                right: bottomBarBg.right
                rightMargin: frameBg.height / 100 * 2.81
            }

            onClicked: {
                if (player.state === "")
                    player.state = "fullscreen"
                else
                    player.state = ""
            }
            status: 0
        }

        Timer {
            id: hidingTimer
            interval: 5000
            onTriggered: {
                if (bottomBarBg.enableAutoHide)
                    bottomBarBg.visible = false
            }
        }

        MouseArea {
            anchors.fill: parent
            onPressed: {
                mouse.accepted = false
                bottomBarBg.restartAutoHide()
            }
        }
    }

    ScreenStateHandler {
        id: forceScreenOn
    }


    function backButtonClicked() {
        Stack.backToMultimedia()
    }

    Component.onCompleted: player.upnp ?
                               global.photoPlayer.generatePlaylistUPnP(player.model, player.index, player.model.count, false) :
                               global.photoPlayer.generatePlaylistLocal(player.model, player.index, player.model.count, false)
    Component.onDestruction: global.photoPlayer.terminate()

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
                sourceSize: Qt.size(fullScreenBg.width, fullScreenBg.height)
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
