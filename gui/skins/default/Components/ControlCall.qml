import QtQuick 1.1
import Components.Text 1.0


Rectangle {
    id: control

    property variant dataObject: undefined

    signal closePopup

    property string description: qsTr("Start call")
    property string headerImage: "../images/common/incoming_call.svg"
    property string place: dataObject.talker
    property string where // used only to make calls

    property int index: 0

    width: 212
    height: 50

    onDataObjectChanged: {
        if(dataObject !== undefined) {
            dataObject.callAnswered.connect(callAnswered)
            dataObject.callEnded.connect(callEnding)
        }
    }

    function callAnswered() {
        control.state = "speaking"
    }

    function callEnding() {
        control.state = ""
        // it is useful to call closePopup as the very last function: this
        // object is destroyed very shortly after the call returns and doing
        // stuff may lead to random crashes
        closePopup()
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

        UbuntuLightText {
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

        UbuntuLightText {
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

        MouseArea {
            id: areaHeader
            anchors.fill: parent
            onClicked: {
                state = "calling"
                dataObject.startCall(where)
            }
        }
    }

    Image {
        id: buttons

        height: 50
        visible: false
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

            UbuntuLightText {
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
                    pixelSize: 10
                    capitalization: Font.AllUppercase
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (dataObject !== undefined)
                        dataObject.answerCall()
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

            UbuntuLightText {
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
                    pixelSize: 10
                    capitalization: Font.AllUppercase
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (dataObject !== undefined)
                        dataObject.endCall()
                    closePopup()
                }
            }
        }
    }

    ControlSlider {
        id: volume
        visible: false

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
        visible: false

        source: "../images/common/btn_annulla.png"
        anchors {
            top: volume.bottom
            left: parent.left
            right: parent.right
        }

        UbuntuLightText {
            anchors {
                fill: parent
                centerIn: parent
            }
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("mute")
            font {
                pixelSize: 12
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
        visible: false
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

            PropertyChanges {
                target: inhibitArea
                visible: true
            }

            PropertyChanges {
                target: mute
                visible: true
            }

            PropertyChanges {
                target: volume
                visible: true
            }

            PropertyChanges {
                target: buttons
                visible: true
            }

            PropertyChanges {
                target: control
                height: 300
                description: qsTr("Incoming Call From")
            }

            PropertyChanges {
                target: areaHeader
                visible: false
            }
        },

        State {
            name: "calling"

            PropertyChanges {
                target: inhibitArea
                visible: true
            }

            PropertyChanges {
                target: mute
                visible: true
            }

            PropertyChanges {
                target: volume
                visible: true
            }

            PropertyChanges {
                target: buttons
                visible: true
            }

            PropertyChanges {
                target: control
                height: 300
                description: qsTr("Call To")
            }

            PropertyChanges {
                target: areaHeader
                visible: false
            }

            PropertyChanges {
                target: answer
                width: 0
            }
        },

        State {
            name: "speaking"

            PropertyChanges {
                target: answer
                width: 0
            }

            PropertyChanges {
                target: buttons
                visible: true
            }

            PropertyChanges {
                target: volume
                visible: true
            }

            PropertyChanges {
                target: mute
                visible: true
            }

            PropertyChanges {
                target: control
                height: 300
                description: qsTr("Call With")
            }

            PropertyChanges {
                target: areaHeader
                visible: false
            }
        }
    ]
}

