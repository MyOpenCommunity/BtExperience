import QtQuick 1.1
import BtObjects 1.0
import BtExperience 1.0
import Components 1.0
import Components.Text 1.0
import "../js/datetime.js" as DateTime
import "../js/EventManager.js" as EventManager
import "../js/Stack.js" as Stack
import "../js/Systems.js" as Script


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

        ButtonImageThreeStates {
            id: alertsButton

            visible: EventManager.eventManager.alarms > 0
            defaultImageBg: "../images/toolbar/_bg_alert.svg"
            pressedImageBg: "../images/toolbar/_bg_alert_pressed.svg"
            defaultImage: "../images/toolbar/icon_alarm.svg"
            pressedImage: "../images/toolbar/icon_alarm_p.svg"

            onClicked: {
                var currentPage = Stack.currentPage()
                if (currentPage._pageName !== "Antintrusion")
                    currentPage = Stack.openPage("Antintrusion.qml")
                currentPage.showLog()
            }

            status: 0
        }

        // antintrusion
        SvgImage {
            visible: EventManager.eventManager.isAntintrusionInserted
            source: imagesPath + "toolbar/toolbar_separator.svg"
            height: toolbar_top.height
        }

        ButtonImageThreeStates {
            id: antintrusionButton

            visible: EventManager.eventManager.isAntintrusionInserted
            defaultImageBg: "../images/toolbar/_bg_alert.svg"
            pressedImageBg: "../images/toolbar/_bg_alert_pressed.svg"
            defaultImage: "../images/toolbar/icon_burlgar alarm-on.svg"
            pressedImage: "../images/toolbar/icon_burlgar alarm-on_p.svg"

            onClicked: Stack.openPage(Script.getTarget(Container.IdAntintrusion))
            status: 0
        }

        // alarm clock
        SvgImage {
            visible: EventManager.eventManager.clocks > 0
            source: imagesPath + "toolbar/toolbar_separator.svg"
            height: toolbar_top.height
        }

        ButtonImageThreeStates {
            id: clockButton

            visible: EventManager.eventManager.clocks > 0
            defaultImageBg: "../images/toolbar/_bg_alert.svg"
            pressedImageBg: "../images/toolbar/_bg_alert_pressed.svg"
            defaultImage: "../images/toolbar/icon_alarm-clock.svg"
            pressedImage: "../images/toolbar/icon_alarm-clock_p.svg"

            onClicked: console.log("clockButton clicked")
            status: 0
        }

        // auto open
        SvgImage {
            visible: EventManager.eventManager.autoOpen
            source: imagesPath + "toolbar/toolbar_separator.svg"
            height: toolbar_top.height
        }

        ButtonImageThreeStates {
            id: autoOpenButton

            visible: EventManager.eventManager.autoOpen
            defaultImageBg: "../images/toolbar/_bg_alert.svg"
            pressedImageBg: "../images/toolbar/_bg_alert_pressed.svg"
            defaultImage: "../images/toolbar/icon_vde-auto-open.svg"
            pressedImage: "../images/toolbar/icon_vde-auto-open_p.svg"

            onClicked: console.log("autoOpenButton clicked")
            status: 0
        }

        // message
        SvgImage {
            visible: EventManager.eventManager.messages > 0
            source: imagesPath + "toolbar/toolbar_separator.svg"
            height: toolbar_top.height
        }

        ButtonImageThreeStates {
            id: messagesButton

            visible: EventManager.eventManager.messages > 0
            defaultImageBg: "../images/toolbar/_bg_alert.svg"
            pressedImageBg: "../images/toolbar/_bg_alert_pressed.svg"
            defaultImage: "../images/toolbar/icon_new-message.svg"
            pressedImage: "../images/toolbar/icon_new-message_p.svg"

            onClicked: Stack.openPage(Script.getTarget(Container.IdMessages))
            status: 0
        }

        // auto answer
        // vde mute
        // volume (and mute)
        // play
        // recording (blinking and not enabled)

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
