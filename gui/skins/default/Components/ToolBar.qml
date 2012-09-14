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

        source: global.guiSettings.skin === 0 ? imagesPath + "toolbar/toolbar_bg_top.svg":
                                                imagesPath + "toolbar/toolbar_bg_top_dark.svg"
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
                defaultImage: global.guiSettings.skin === 0 ? imagesPath + "toolbar/icon_home.svg":
                                                              imagesPath + "toolbar/icon_home_pressed.svg"
                pressedImage: global.guiSettings.skin === 0 ? imagesPath + "toolbar/icon_home_pressed.svg":
                                                              imagesPath + "toolbar/icon_home.svg"
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
                color: global.guiSettings.skin === 0 ? "black":
                                                       "white"
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
                color: global.guiSettings.skin === 0 ? "black":
                                                       "white"
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
                color: global.guiSettings.skin === 0 ? "black":
                                                       "white"
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
        source: global.guiSettings.skin === 0 ? imagesPath + "toolbar/toolbar_logo_black.svg" :
                                                imagesPath + "toolbar/toolbar_logo_white.svg"
        anchors.verticalCenter: toolbar_top.verticalCenter
        anchors.horizontalCenter: toolbar_top.horizontalCenter
    }

    Row {
        id: toolbarRight
        anchors.right: toolbar_top.right
        anchors.verticalCenter: toolbar_top.verticalCenter

        // antintrusion
        ToolbarButton {
            height: toolbar_top.height
            defaultImage: EventManager.eventManager.isAntintrusionInserted ?
                              (global.guiSettings.skin === 0 ?
                                   "../images/toolbar/icon_burlgar alarm-on.svg" :
                                   "../images/toolbar/icon_burlgar alarm-on_p.svg") :
                              (global.guiSettings.skin === 0 ?
                                   "../images/toolbar/icon_alarm-disabled.svg" :
                                   "../images/toolbar/icon_alarm-disabled_p.svg")
            pressedImage:  EventManager.eventManager.isAntintrusionInserted ?
                               (global.guiSettings.skin === 0 ?
                                    "../images/toolbar/icon_burlgar alarm-on_p.svg" :
                                    "../images/toolbar/icon_burlgar alarm-on.svg") :
                               (global.guiSettings.skin === 0 ?
                                    "../images/toolbar/icon_alarm-disabled_p.svg" :
                                    "../images/toolbar/icon_alarm-disabled.svg")
            onClicked: Stack.openPage(Script.getTarget(Container.IdAntintrusion))
        }

        // alarm clock
        ToolbarButton {
            height: toolbar_top.height
            visible: EventManager.eventManager.clocks > 0
            defaultImage: global.guiSettings.skin === 0 ?
                              "../images/toolbar/icon_alarm-clock.svg" :
                              "../images/toolbar/icon_alarm-clock_p.svg"
            pressedImage: global.guiSettings.skin === 0 ?
                              "../images/toolbar/icon_alarm-clock_p.svg" :
                              "../images/toolbar/icon_alarm-clock.svg"
            onClicked: console.log("clockButton clicked")
        }

        // auto open
        ToolbarButton {
            height: toolbar_top.height
            visible: EventManager.eventManager.autoOpen
            defaultImage: global.guiSettings.skin === 0 ?
                              "../images/toolbar/icon_vde-auto-open.svg" :
                              "../images/toolbar/icon_vde-auto-open_p.svg"
            pressedImage: global.guiSettings.skin === 0 ?
                              "../images/toolbar/icon_vde-auto-open_p.svg" :
                              "../images/toolbar/icon_vde-auto-open.svg"
            onClicked: console.log("autoOpenButton clicked")
        }

        // auto answer
        ToolbarButton {
            height: toolbar_top.height
            visible: EventManager.eventManager.autoAnswer
            defaultImage: global.guiSettings.skin === 0 ?
                              "../images/toolbar/icon_vde-auto-answer.svg" :
                              "../images/toolbar/icon_vde-auto-answer_p.svg"
            pressedImage: global.guiSettings.skin === 0 ?
                              "../images/toolbar/icon_vde-auto-answer_p.svg" :
                              "../images/toolbar/icon_vde-auto-answer.svg"
            onClicked: console.log("autoAnswerButton clicked")
        }

        // vde mute
        ToolbarButton {
            height: toolbar_top.height
            visible: EventManager.eventManager.vdeMute
            defaultImage: global.guiSettings.skin === 0 ?
                              "../images/toolbar/icon_vde-mute.svg" :
                              "../images/toolbar/icon_vde-mute_p.svg"
            pressedImage: global.guiSettings.skin === 0 ?
                              "../images/toolbar/icon_vde-mute_p.svg" :
                              "../images/toolbar/icon_vde-mute.svg"
            onClicked: console.log("vdeMuteButton clicked")
        }

        // alerts
        ToolbarButton {
            height: toolbar_top.height
            visible: EventManager.eventManager.alarms > 0
            defaultImage: global.guiSettings.skin === 0 ?
                              "../images/toolbar/icon_alarm.svg" :
                              "../images/toolbar/icon_alarm_p.svg"
            pressedImage: global.guiSettings.skin === 0 ?
                              "../images/toolbar/icon_alarm_p.svg" :
                              "../images/toolbar/icon_alarm.svg"
            onClicked: {
                var currentPage = Stack.currentPage()
                if (currentPage._pageName !== "Antintrusion")
                    currentPage = Stack.openPage("Antintrusion.qml")
                currentPage.showLog()
            }
        }

        // volume (and mute)
        ToolbarButton {
            height: toolbar_top.height
            visible: EventManager.eventManager.playing
            defaultImage: EventManager.eventManager.mute ?
                              (global.guiSettings.skin === 0 ?
                                   "../images/toolbar/icon_audio-source-on.svg" :
                                   "../images/toolbar/icon_audio-source-on_p.svg") :
                              (global.guiSettings.skin === 0 ?
                                   "../images/toolbar/icon_source-audio-mute.svg" :
                                   "../images/toolbar/icon_source-audio-mute_p.svg")
            pressedImage: EventManager.eventManager.mute ?
                              (global.guiSettings.skin === 0 ?
                                   "../images/toolbar/icon_audio-source-on_p.svg" :
                                   "../images/toolbar/icon_audio-source-on.svg") :
                              (global.guiSettings.skin === 0 ?
                                   "../images/toolbar/icon_source-audio-mute_p.svg" :
                                   "../images/toolbar/icon_source-audio-mute.svg")
            // TODO come recuperare il modello da usare (local, upnp) e come impostare rootPath e index corretti?
            onClicked: console.log("volumeButton clicked")
        }

        // play
        ToolbarButton {
            height: toolbar_top.height
            visible: EventManager.eventManager.playing
            defaultImage: global.guiSettings.skin === 0 ?
                              "../images/toolbar/icon_source-play.svg" :
                              "../images/toolbar/icon_source-play_p.svg"
            pressedImage: global.guiSettings.skin === 0 ?
                              "../images/toolbar/icon_source-play_p.svg" :
                              "../images/toolbar/icon_source-play.svg"
            // TODO come recuperare il modello da usare (local, upnp) e come impostare rootPath e index corretti?
            onClicked: console.log("playButton clicked")
        }

        // message
        ToolbarButton {
            height: toolbar_top.height
            visible: EventManager.eventManager.messages > 0
            defaultImage: global.guiSettings.skin === 0 ?
                              "../images/toolbar/icon_new-message.svg" :
                              "../images/toolbar/icon_new-message_p.svg"
            pressedImage: global.guiSettings.skin === 0 ?
                              "../images/toolbar/icon_new-message_p.svg" :
                              "../images/toolbar/icon_new-message.svg"
            onClicked: Stack.openPage(Script.getTarget(Container.IdMessages))
        }

        // recording
        ToolbarButton {
            height: toolbar_top.height
            visible: EventManager.eventManager.scenarioRecording
            blinking: EventManager.eventManager.scenarioRecording
            blinkingInterval: 500
            defaultImage: global.guiSettings.skin === 0 ?
                              "../images/toolbar/icon_scenario-recording.svg" :
                              "../images/toolbar/icon_scenario-recording_p.svg"
            enabled: false
        }

        // energy, stop&go danger
        ToolbarButton {
            height: toolbar_top.height
            visible: EventManager.eventManager.danger
            defaultImage: global.guiSettings.skin === 0 ?
                              "../images/toolbar/icon_energy.svg" :
                              "../images/toolbar/icon_energy_p.svg"
            pressedImage: global.guiSettings.skin === 0 ?
                              "../images/toolbar/icon_energy_p.svg" :
                              "../images/toolbar/icon_energy.svg"
            onClicked: console.log("dangerButton clicked")
        }

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
