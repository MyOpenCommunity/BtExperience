import QtQuick 1.1
import Components 1.0
import "js/Stack.js" as Stack


Page {
    id: videoCamera

    property QtObject camera: null

    property string title: qsTr("TELECAMERA POSTO ESTERNO 1")
    property int volume: 50
    property bool commandAnswerVisible: true
    property bool commandStairLightVisible: true
    property bool commandLockVisible: true
    property bool brightnessVisible: true
    property bool contrastVisible: true
    property bool volumeVisible: true
    property string description1: qsTr("Active call with")
    property string replayImage: "images/common/bg_DueRegolazioni.png"
    property string replayText: "REPLAY"
    property int replayMargin: 25
    property string endCallImage: "images/common/bg_DueRegolazioni.png"
    property string endCallText: "END CALL"
    property int endCallMargin: 25

    signal nextCameraClicked
    signal muteClicked
    signal minusVolumeClicked
    signal plusVolumeClicked
    signal replayClicked
    signal endCallClicked

    function callEndRequested() {
        camera.videoIsStopped.connect(Stack.popPage)
    }

    Component.onCompleted: {
        camera.callEndRequested.connect(callEndRequested)
    }

    function endCall(callback) {
        // TODO: possible race condition on videoIsStopped? I think it's possible
        // to pop two pages if timings are right...
        camera.videoIsStopped.connect(callback)
        camera.endCall()
    }

    Image {
        source: "images/videocitofonia.jpg"
        anchors.fill: parent
        Rectangle {
            id: bg
            anchors.fill: parent
            color: "black"
            opacity: 0.75

            ToolBar {
                id: toolbar
                fontFamily: semiBoldFont.name
                fontSize: 17
                onHomeClicked: endCall(Stack.backToHome)
            }

            Column {
                id: buttonsColumn
                width: backButton.width
                spacing: 10
                anchors {
                    top: toolbar.bottom
                    left: parent.left
                    topMargin: 35
                    leftMargin: 20
                }

                ButtonBack {
                    id: backButton
                    onClicked: endCall(Stack.popPage)
                }

                // TODO: reenable it after May demo! :)
//                ButtonSystems {
//                    // 1 is systems page
//                    onClicked: Stack.showPreviousPage(1)
//                }
            }

            Text {
                id: title
                text: videoCamera.title
                color: "white"
                x: 90
                y: 65
                font.family: semiBoldFont.name
                font.pixelSize: 18
            }

            Image {
                id: video
                source: "images/videocitofonia.jpg"
                x: 90
                y: 90
                width: 640
                height: 480
            }

            Image {
                id: next
                source: "images/common/successivo.png"
                x: 796
                y: 56
                width: 28
                height: 28
                MouseArea {
                    anchors.fill: parent
                    onClicked: videoCamera.nextCameraClicked()
                }
            }

            Column {
                id: propertyColumn
                width: 145
                spacing: 10
                anchors {
                    top: toolbar.bottom
                    right: parent.right
                    topMargin: 20
                    rightMargin: 20
                }

                ControlSlider2 {
                    visible: videoCamera.volumeVisible
                    title: qsTr("VOLUME")
                    value: videoCamera.volume
                    onPlusClicked: videoCamera.plusVolumeClicked()
                    onMinusClicked: videoCamera.minusVolumeClicked()
                }
                Image {
                    source: "images/common/btn_comando.png"
                    width: parent.width
                    height: 40
                    MouseArea {
                        anchors.fill: parent
                        onClicked: videoCamera.muteClicked()
                    }
                    Text {
                        text: qsTr("MUTE")
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            verticalCenter: parent.verticalCenter
                        }
                    }
                }

                ControlSlider2 {
                    visible: videoCamera.brightnessVisible
                    title: qsTr("BRIGHTNESS")
                    value: camera.brightness
                    onPlusClicked: if (camera.brightness < 100) camera.brightness += 1
                    onMinusClicked: if (camera.brightness > 00) camera.brightness -= 1
                }

                ControlSlider2 {
                    visible: videoCamera.contrastVisible
                    title: qsTr("CONTRAST")
                    value: camera.contrast
                    onPlusClicked: if (camera.contrast < 100) camera.contrast += 1
                    onMinusClicked: if (camera.contrast > 00) camera.contrast -= 1
                }
            }

            Column {
                id: commandColumn
                width: 145
                spacing: 10
                anchors {
                    bottom: parent.bottom
                    right: parent.right
                    bottomMargin: 34
                    rightMargin: 20
                }

                Image {
                    source: "images/common/btn_comando.png"
                    visible: videoCamera.commandStairLightVisible
                    width: 145
                    height: 40
                    MouseArea {
                        anchors.fill: parent
                        onPressed: camera.onStairLightActivate()
                        onReleased: camera.onStairLightRelease()
                    }
                    Text {
                        text: qsTr("STAIRLIGHT")
                        font.pointSize: 10
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            verticalCenter: parent.verticalCenter
                        }
                    }
                }

                Image {
                    source: "images/common/btn_comando.png"
                    visible: videoCamera.commandLockVisible
                    width: 145
                    height: 40
                    MouseArea {
                        anchors.fill: parent
                        onPressed: camera.openLock()
                        onReleased: camera.releaseLock()
                    }
                    Text {
                        text: qsTr("OPEN LOCK")
                        font.pointSize: 10
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            verticalCenter: parent.verticalCenter
                        }
                    }
                }

                Image {
                    source: "images/common/btn_comando.png"
                    visible: videoCamera.commandAnswerVisible
                    width: 145
                    height: 40
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            console.log("Audio button clicked")
                            videoCamera.camera.answerCall()
                        }
                    }
                    Text {
                        text: qsTr("ANSWER CALL")
                        font.pointSize: 10
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }
        }
    }
}
