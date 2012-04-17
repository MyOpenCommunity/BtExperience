import QtQuick 1.1

Item {
    id: control
    width: 212

    property string callImage: "../images/common/bg_codice_ok.png"
    property string name: "Start call"
    property string description: "External place 1"
    property string leftText: "Replay"
    property int leftTextMargin: 25
    property string leftImage: "../images/common/bg_DueRegolazioni.png"
    property string rightText: "End Call"
    property int rightTextMargin: 25
    property string rightImage: "../images/common/bg_DueRegolazioni.png"
    property string sliderDescription: "Volume"
    property int percentage: 50
    property string downText: "Mute"
    property string downImage: "../images/common/bg_DueRegolazioni.png"

    signal minusClicked
    signal plusClicked
    signal controlClicked
    signal leftButtonClicked
    signal stopCallClicked
    signal muteClicked

    Column {
        Image {
            width: 212
            height: 50
            source: "../images/common/bg_DueRegolazioni.png"
            Row {
                Column {
                    Text {
                        id: textName
                        height: control.description == "" ? 50 : 25
                        width: 162
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: control.name
                        MouseArea {
                            anchors.fill: parent
                            onClicked: control.controlClicked()
                        }
                    }
                    Text {
                        id: textDescription
                        height: 25
                        color: "#ffffff"
                        width: 162
                        visible: control.description == "" ? false : true
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: control.description
                        MouseArea {
                            anchors.fill: parent
                            onClicked: control.controlClicked()
                        }
                    }
                }
                Image {
                    source: control.callImage
                    visible: control.callImage == "" ? false : true
                    height: 50
                    width: 50
                    MouseArea {
                        anchors.fill: parent
                        onClicked: control.controlClicked()
                    }
                }
            }
        }
        Row {
            id: buttons
            Image {
                id: leftButton
                source: control.leftImage
                width: 106
                height: 50
                visible: control.leftImage == "" ? false : true
                Text {
                    color: "#ffffff"
                    anchors {
                        fill: parent
                        horizontalCenter: parent.horizontalCenter
                        leftMargin: control.leftTextMargin
                    }
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: control.leftText
                    font {
                        pointSize: 10
                        capitalization: Font.AllUppercase
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: control.leftButtonClicked()
                }
            }
            Image {
                id: rightButton
                source: control.rightImage
                width: leftButton.visible ? 106 : 212
                height: 50
                visible: control.rightImage == "" ? false : true
                Text {
                    color: "#ffffff"
                    anchors {
                        fill: parent
                        horizontalCenter: parent.horizontalCenter
                        leftMargin: control.rightTextMargin
                    }
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: control.rightText
                    font {
                        pointSize: 10
                        capitalization: Font.AllUppercase
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: control.stopCallClicked()
                }
            }
        }
        ControlSlider {
            id: controlSlider
            description: control.sliderDescription
            percentage: control.percentage
            onMinusClicked: control.minusClicked()
            onPlusClicked: control.plusClicked()
        }
        Image {
            id: downButton
            source: control.downImage
            width: 212
            height: 50
            visible: control.downImage == "" ? false : true
            Text {
                anchors {
                    fill: parent
                    horizontalCenter: parent.horizontalCenter
                }
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                text: control.downText
                font {
                    pointSize: 12
                    capitalization: Font.AllUppercase
                }
            }
            MouseArea {
                id: downButtonArea
                anchors.fill: parent
                onClicked: control.muteClicked()
            }
        }
    }
    Rectangle {
        id: area
        x: 0
        y: 100
        width: 212
        height: 200
        color: "black"
        opacity: 0
        Behavior on opacity {
            NumberAnimation { duration: constants.alertTransitionDuration }
        }
        z: 10

        MouseArea {
            anchors.fill: parent
        }
    }

    Constants {
        id: constants
    }

    states: [
        State {
            name: "command"

            PropertyChanges {
                target: buttons
                visible: false
            }

            PropertyChanges {
                target: controlSlider
                visible: false
            }

            PropertyChanges {
                target: downButton
                visible: false
            }
        },
        State {
            name: "Ring1"

            PropertyChanges {
                target: controlSlider
                visible: false
            }

            PropertyChanges {
                target: downButton
                visible: false
            }
        },
        State {
            name: "outgoingCall"

            PropertyChanges {
                target: area
                opacity: 0.75
            }
        },
        State {
            name: "noAnswer"

            PropertyChanges {
                target: control
                name: qsTr("No answer")
                callImage: "../images/common/bg_codice_errato.png"
            }
            PropertyChanges {
                target: area
                opacity: 0.75
            }
            PropertyChanges {
                target: noAnswerTimer
                running: true
            }
        }
    ]

    Timer {
        id: noAnswerTimer
        interval: 1500
        onTriggered: control.state = "command"
    }
}
