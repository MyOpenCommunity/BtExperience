import QtQuick 1.1
import BtExperience 1.0
import Components 1.0
import Components.Text 1.0
import "../js/datetime.js" as DateTime
import "../js/EventManager.js" as EventManager


Item {
    id: toolbar

    property string imagesPath: "../images/"
    property int fontSize: 14
    signal homeClicked

    width: 1024
    height: toolbar_top.height + toolbar_bottom.height

    SvgImage {
        id: toolbar_top
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        source: imagesPath + "toolbar/toolbar_bg_top.svg"
        width: parent.width
    }

    Row {
        id: toolbarLeft
        anchors.verticalCenter: toolbar_top.verticalCenter
        anchors.left: toolbar_top.left

        Item {
            width: 120
            height: toolbar_top.height

            ButtonImageThreeStates {
                defaultImageBg: imagesPath + "toolbar/bg_home.svg"
                pressedImageBg: imagesPath + "toolbar/bg_home_pressed.svg"
                defaultImage: imagesPath + "toolbar/icon_home.svg"
                pressedImage: imagesPath + "toolbar/icon_home_pressed.svg"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                onClicked: toolbar.homeClicked() //doStuff()
            }
        }

        SvgImage {
            source: imagesPath + "toolbar/toolbar_separator.svg"
            height: toolbar_top.height
        }

        Item {
            width: 64
            height: toolbar_top.height

            UbuntuLightText {
                id: temperature
                text: "19°C"
                font.pixelSize: toolbar.fontSize
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        SvgImage {
            source: imagesPath + "toolbar/toolbar_separator.svg"
            height: toolbar_top.height
        }

        Item {
            width: 99
            height: toolbar_top.height

            UbuntuLightText {
                id: date
                font.pixelSize: toolbar.fontSize
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                function setDate(d) {
                    text = DateTime.format(d)["date"]
                }
            }
        }


        SvgImage {
            source: imagesPath + "toolbar/toolbar_separator.svg"
            height: toolbar_top.height
        }

        Item {
            width: 64
            height: toolbar_top.height

            UbuntuLightText {
                id: time
                text: DateTime.format()["time"]
                font.pixelSize: toolbar.fontSize
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                function setTime(d) {
                    text = DateTime.format(d)["time"]
                }
            }
        }

        Timer {
            id: changeDateTime
            interval: 500
            repeat: true
            running: true
            triggeredOnStart: true
            onTriggered: { var d = new Date(); date.setDate(d); time.setTime(d) }
        }

        SvgImage {
            source: imagesPath + "toolbar/toolbar_separator.svg"
            height: toolbar_top.height
        }
    }

    SvgImage {
        source: imagesPath + "toolbar/toolbar_logo_black.svg"
        anchors.verticalCenter: toolbar_top.verticalCenter
        anchors.horizontalCenter: toolbar_top.horizontalCenter
    }

    Row {
        id: toolbarRight
        anchors.right: toolbar_top.right
        anchors.verticalCenter: toolbar_top.verticalCenter

        // alerts
        SvgImage {
            visible: EventManager.eventManager.alarms > 0
            source: imagesPath + "toolbar/toolbar_separator.svg"
            height: toolbar_top.height
        }

        Item {
            visible: EventManager.eventManager.alarms > 0
            width: 51
            height: toolbar_top.height + 10

            ButtonImageThreeStates {
                id: alertsButton

                width: 51
                height: toolbar_top.height + 10
                visible: EventManager.eventManager.alarms > 0

                defaultImageBg: "../images/toolbar/bg_icon.svg"
                pressedImageBg: "../images/toolbar/bg_icon_P.svg"
                shadowImage: "../images/toolbar/icon_alert_shadow.svg"
                defaultImage: "../images/toolbar/icon_alert.svg"
                pressedImage: "../images/toolbar/icon_alert_P.svg"
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }

                onClicked: console.log("alertsButton clicked")
                status: 0
            }
        }

        // antintrusion
        SvgImage {
            visible: EventManager.eventManager.isAntintrusionInserted
            source: imagesPath + "toolbar/toolbar_separator.svg"
            height: toolbar_top.height
        }

        Item {
            visible: EventManager.eventManager.isAntintrusionInserted
            width: 51
            height: toolbar_top.height + 10

            ButtonImageThreeStates {
                id: antintrusionButton

                width: 51
                height: toolbar_top.height + 10
                visible: EventManager.eventManager.alarms > 0

                defaultImageBg: "../images/toolbar/bg_icon.svg"
                pressedImageBg: "../images/toolbar/bg_icon_P.svg"
                shadowImage: "../images/toolbar/icon_antintrusion_shadow.svg"
                defaultImage: "../images/toolbar/icon_antintrusion.svg"
                pressedImage: "../images/toolbar/icon_antintrusion_P.svg"
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }

                onClicked: console.log("antintrusionButton clicked")
                status: 0
            }
        }

        // alarm clock
        SvgImage {
            visible: EventManager.eventManager.clocks > 0
            source: imagesPath + "toolbar/toolbar_separator.svg"
            height: toolbar_top.height
        }

        Item {
            visible: EventManager.eventManager.clocks > 0
            width: 51
            height: toolbar_top.height + 10

            ButtonImageThreeStates {
                id: clockButton

                width: 51
                height: toolbar_top.height + 10
                visible: EventManager.eventManager.clocks > 0

                defaultImageBg: "../images/toolbar/bg_icon.svg"
                pressedImageBg: "../images/toolbar/bg_icon_P.svg"
                shadowImage: "../images/toolbar/icon_clock_shadow.svg"
                defaultImage: "../images/toolbar/icon_clock.svg"
                pressedImage: "../images/toolbar/icon_clock_P.svg"
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }

                onClicked: console.log("clockButton clicked")
                status: 0
            }
        }

        // auto answer
        // auto open
        // vde mute
        // volume (and mute)
        // play
        // message
        // recording

    }

    SvgImage {
        id: toolbar_bottom
        anchors.top: toolbar_top.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        source: imagesPath + "toolbar/toolbar_bg_bottom.svg"
        width: parent.width
    }
}
