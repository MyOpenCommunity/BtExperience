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

    Rectangle {
        id: fullScreenBg

        color: "black"
        anchors.fill: parent

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
        // Shrink memory size preserving the aspect ratio
        sourceSize.height: fullScreenBg.height
        // Show photo in fullscreen preserving the aspect ratio
        // TODO: small photos are really ugly, what to do?
        fillMode: Image.PreserveAspectFit
        anchors.fill: parent
        cache: false
    }

    SvgImage {
        id: bottomBarBg

        function restartAutoHide() {
            hidingTimer.restart()
        }

        source: "images/common/bg_player_fullscreen.svg"
        anchors {
            bottom: fullScreenBg.bottom
            horizontalCenter: fullScreenBg.horizontalCenter
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
                leftMargin: fullScreenBg.width / 100 * 2
            }

            onClicked: global.photoPlayer.prevPhoto()
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
                leftMargin: fullScreenBg.width / 100 * 0.5
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
                leftMargin: fullScreenBg.width / 100 * 0.5
            }

            onClicked: global.photoPlayer.nextPhoto()
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
                leftMargin: fullScreenBg.width / 100 * 1.5
            }

            onClicked: Stack.backToPage("Devices.qml")
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
                rightMargin: fullScreenBg.width / 100 * 2
            }

            onClicked: Stack.backToPage("Devices.qml")
            status: 1
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
}
