import QtQuick 1.1
import Components 1.0
import Components.Text 1.0
import "js/Stack.js" as Stack


Page {
    id: videoCamera
    source: "images/videocitofonia.jpg"

    property QtObject camera: null

    property string title: qsTr("CAMERA EXTERNAL PLACE #1")
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

    function endCall(callback) {
        camera.callEnded.disconnect(Stack.popPage)
        camera.endCall()
        callback()
    }

    function homeButtonClicked() {
        endCall(Stack.backToHome)
    }

    function backButtonClicked() {
        endCall(Stack.popPage)
    }

    text: qsTr("video")
    showSystemsButton: false

    Rectangle {
        id: bg
        anchors.fill: parent
        color: "black"
        opacity: 0.75



        UbuntuLightText {
            id: title
            text: videoCamera.title
            color: "white"
            x: 103
            y: 65
            font.pixelSize: 18
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
            id: commandColumn
            x: 590
            y: 434
            width: 145
            spacing: 10
            anchors {
                bottom: parent.bottom
                right: parent.right
                bottomMargin: 26
                rightMargin: 65
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
                UbuntuLightText {
                    text: qsTr("STAIRLIGHT")
                    font.pixelSize: 13
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
                UbuntuLightText {
                    text: qsTr("OPEN LOCK")
                    font.pixelSize: 13
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
                UbuntuLightText {
                    text: qsTr("ANSWER CALL")
                    font.pixelSize: 13
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }

    Column {
        id: propertyColumn
        x: 590
        width: 145
        spacing: 10
        anchors {
            top: toolbar.bottom
            right: parent.right
            topMargin: 20
            rightMargin: 65
        }

        ControlSlider {
            visible: videoCamera.volumeVisible
            description: qsTr("VOLUME")
            percentage: videoCamera.volume
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
            UbuntuLightText {
                text: qsTr("MUTE")
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }
            }
        }

        ControlSlider {
            visible: videoCamera.brightnessVisible
            description: qsTr("BRIGHTNESS")
            percentage: camera.brightness
            onPlusClicked: if (camera.brightness < 100) camera.brightness += 1
            onMinusClicked: if (camera.brightness > 0) camera.brightness -= 1
        }

        ControlSlider {
            visible: videoCamera.contrastVisible
            description: qsTr("CONTRAST")
            percentage: camera.contrast
            onPlusClicked: if (camera.contrast < 100) camera.contrast += 1
            onMinusClicked: if (camera.contrast > 0) camera.contrast -= 1
        }
    }

    Rectangle {
        id: bg_video
        color: "red"
        x: 112
        y: 96
        width: 640
        height: 480
    }

    Component.onCompleted: {
        camera.callEnded.connect(Stack.popPage)
        toolbar.z = 1
        navigationBar.z = 1
    }
}
