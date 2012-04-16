import QtQuick 1.1
import Components 1.0
import "js/Stack.js" as Stack


SystemPage {
    id: page

    property string title: qsTr("TELECAMERA POSTO ESTERNO 1")
    property int brightness: 50
    property int contrast: 50
    property int volume: 50
    property string command1Text: qsTr("ATTIVA AUDIO")
    property string command2Text: qsTr("ACCENDI LUCE")
    property string command3Text: qsTr("APRI CANCELLETTO")
    property bool command1Visible: true
    property bool command2Visible: true
    property bool command3Visible: true
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
    signal minusBrightnessClicked
    signal plusBrightnessClicked
    signal minusContrastClicked
    signal plusContrastClicked
    signal command1Clicked
    signal command2Clicked
    signal command3Clicked
    signal muteClicked
    signal minusVolumeClicked
    signal plusVolumeClicked
    signal replayClicked
    signal endCallClicked

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
                onHomeClicked: Stack.backToHome()
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
                    onClicked: Stack.popPage()
                }

                ButtonSystems {
                    // 1 is systems page
                    onClicked: Stack.showPreviousPage(1)
                }
            }

            Text {
                id: title
                text: page.title
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
                width: 735
                height: 486
                Rectangle {
                    color: "black"
                    opacity: 0.75
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        bottom: parent.bottom
                        bottomMargin: 56
                    }
                    width: 566
                    height: 46
                    Text {
                        text: page.description1
                        color: "white"
                        anchors {
                            top: parent.top
                            left: parent.left
                            topMargin: 5
                            leftMargin: 5
                        }
                    }
                    Text {
                        text: page.title
                        color: "white"
                        anchors {
                            bottom: parent.bottom
                            left: parent.left
                            bottomMargin: 5
                            leftMargin: 5
                        }
                    }
                    Row {
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                        }
                        ButtonImageText {
                            id: leftButton
                            width: 105
                            height: 46
                            source: page.replayImage
                            text: page.replayText
                            textMargin: page.replayMargin
                            onClicked: page.replayClicked()
                        }
                        ButtonImageText {
                            id: rightButton
                            width: leftButton.visible ? 105 : 210
                            height: 46
                            source: page.endCallImage
                            text: page.endCallText
                            textMargin: page.endCallMargin
                            onClicked: page.endCallClicked()
                        }
                    }
                }
            }

            Image {
                id: next
                source: "images/videocitofonia.jpg"
                x: 796
                y: 56
                width: 28
                height: 28
                MouseArea {
                    anchors.fill: parent
                    onClicked: page.nextCameraClicked()
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
                    visible: page.volumeVisible
                    title: qsTr("VOLUME")
                    value: page.volume
                    onPlusClicked: page.plusVolumeClicked()
                    onMinusClicked: page.minusVolumeClicked()
                }
                Image {
                    source: "images/common/btn_comando.png"
                    width: parent.width
                    height: 40
                    MouseArea {
                        anchors.fill: parent
                        onClicked: page.muteClicked()
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
                    visible: page.brightnessVisible
                    title: qsTr("BRIGHTNESS")
                    value: page.brightness
                    onPlusClicked: page.plusBrightnessClicked()
                    onMinusClicked: page.minusBrightnessClicked()
                }

                ControlSlider2 {
                    visible: page.contrastVisible
                    title: qsTr("CONTRAST")
                    value: page.contrast
                    onPlusClicked: page.plusContrastClicked()
                    onMinusClicked: page.minusContrastClicked()
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
                    visible: page.command1Visible
                    width: 145
                    height: 40
                    MouseArea {
                        anchors.fill: parent
                        onClicked: page.command1Clicked()
                    }
                    Text {
                        text: page.command1Text
                        font.pointSize: 10
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            verticalCenter: parent.verticalCenter
                        }
                    }
                }

                Image {
                    source: "images/common/btn_comando.png"
                    visible: page.command2Visible
                    width: 145
                    height: 40
                    MouseArea {
                        anchors.fill: parent
                        onClicked: page.command2Clicked()
                    }
                    Text {
                        text: page.command2Text
                        font.pointSize: 10
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            verticalCenter: parent.verticalCenter
                        }
                    }
                }

                Image {
                    source: "images/common/btn_comando.png"
                    visible: page.command3Visible
                    width: 145
                    height: 40
                    MouseArea {
                        anchors.fill: parent
                        onClicked: page.command3Clicked()
                    }
                    Text {
                        text: page.command3Text
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
