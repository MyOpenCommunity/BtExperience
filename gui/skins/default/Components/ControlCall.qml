import QtQuick 1.1

Rectangle {
    id: control

    property variant callManager: undefined

    signal closePopup

    property string description: qsTr("Chiamata in arrivo da")
    property string headerImage: "../images/common/incoming_call.svg"
    property string place: "Soggiorno"

    width: 212
    height: 300

    onCallManagerChanged: {
        if(callManager !== undefined)
            control.callManager.callEnded.connect(closePopup)
    }

    Image {
        id: header

        height: 50
        source: "../images/common/bg_DueRegolazioni.png"
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        Text {
            id: textDescription

            anchors {
                top: parent.top
                left: parent.left
                right:imageHeader.left
                bottom: textPlace.top
            }
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            text: control.description
        }

        Text {
            id: textPlace

            anchors {
                bottom: parent.bottom
                left: parent.left
                right: imageHeader.left
            }
            height: parent.height / 2
            color: "white"
            visible: control.place == "" ? false : true
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            text: control.place
        }

        SvgImage {
            id: imageHeader

            anchors {
                top: parent.top
                bottom: parent.bottom
                right: parent.right
            }
            width: parent.width / 4
            source: control.headerImage
            visible: control.headerImage == "" ? false : true
        }
    }

    Image {
        id: buttons

        height: 50
        source: "../images/common/bg_DueRegolazioni.png"
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
        }

        Rectangle {
            id: answer

            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
            }

            color: "green"
            width: parent.width / 2

            SvgImage {
                id: imageAnswer

                anchors {
                    top: parent.top
                    topMargin: parent.width / 20
                    bottom: parent.bottom
                    bottomMargin: parent.width / 20
                    left: parent.left
                    leftMargin: parent.width / 20
                }
                width: parent.width / 3
                source: "../images/common/answer_call.svg"
            }

            Text {
                color: "white"
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    right: parent.right
                }
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("Answer")
                font {
                    pointSize: 10
                    capitalization: Font.AllUppercase
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (callManager !== undefined)
                        callManager.answerCall()
                    control.state = "speaking"
                }
            }
        }

        Rectangle {
            id: end

            anchors {
                top: parent.top
                bottom: parent.bottom
                right: parent.right
                left: answer.right
            }

            color: "red"

            SvgImage {
                id: imageEnd

                anchors {
                    top: parent.top
                    topMargin: parent.width / 20
                    bottom: parent.bottom
                    bottomMargin: parent.width / 20
                    left: parent.left
                    leftMargin: parent.width / 20
                }
                width: parent.width / 3
                source: "../images/common/end_call.svg"
            }

            Text {
                color: "white"
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    right: parent.right
                }
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("End Call")
                font {
                    pointSize: 10
                    capitalization: Font.AllUppercase
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (callManager !== undefined)
                        callManager.endCall()
                    closePopup()
                }
            }
        }
    }

    ControlSlider {
        id: volume

        source: "../images/common/bg_DueRegolazioni.png"
        anchors {
            top: buttons.bottom
            left: parent.left
            right: parent.right
        }
        description: qsTr("volume")
        percentage: 50
    }

    Image {
        id: mute

        source: "../images/common/btn_annulla.png"
        anchors {
            top: volume.bottom
            left: parent.left
            right: parent.right
        }

        Text {
            anchors {
                fill: parent
                centerIn: parent
            }
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("mute")
            font {
                pointSize: 12
                capitalization: Font.AllUppercase
            }
        }
    }

    Rectangle {
        id: inhibitArea

        anchors {
            top: volume.top
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        color: "black"
        opacity: 0.7
        z: 10

        Behavior on opacity {
            NumberAnimation { duration: constants.alertTransitionDuration }
        }

        MouseArea {
            anchors.fill: parent
        }
    }

    Constants {
        id: constants
    }

    states: [
        State {
            name: "ringing"
        },
        State {
            name: "speaking"
            PropertyChanges { target: answer; width: 0 }
            PropertyChanges { target: inhibitArea; visible: false }
            PropertyChanges { target: control; description: qsTr("Chiamata in corso con") }
        }
    ]
}

