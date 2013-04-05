import QtQuick 1.1
import BtObjects 1.0
import BtExperience 1.0
import Components 1.0
import Components.Text 1.0
import "../js/datetime.js" as DateTime
import "../js/EventManager.js" as EventManager
import "../js/Stack.js" as Stack
import "../js/Systems.js" as Script
import "../js/navigation.js" as Navigation


/**
  \ingroup Core

  \brief The main application toolbar.

  This component defines a toolbar used in several application pages.
  It contains a home button, actual date and time plus some optional buttons.
  A temperature probe may be present, too.
  The home button let the user always navigate back to HomePage.
  Actual date and time may be clicked and bring the user to the setting page
  where system date and time may be modified.
  On the right several optional buttons may appear. These buttons appear when
  they are configured to do so and if some conditions hold (for example, the
  alarm clock button appears when at least one alarm clock is active).
  Clicking on them, the user navigates to the relevant section of the application.
  For example, clicking on the alarm clock button when present, lead to the
  alarm clock settings page.
  Only the scenario recording button is different. It cannot be clicked and it
  blinks till the scenario recording is in progress.
  */
Item {
    id: toolbar

    property string imagesPath: "../images/"
    property int fontSize: 14
    property alias helpUrl: helpToolbarButton.helpUrl // sets url for context help

    /// home button was clicked
    signal homeClicked
    /// an optional toolbar button was clicked
    signal toolbarNavigationClicked

    width: 1024
    height: toolbar_top.height + toolbar_bottom.height

    SvgImage {
        id: toolbar_top
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        source: homeProperties.skin === HomeProperties.Clear ? imagesPath + "toolbar/toolbar_bg_top.svg":
                                                               imagesPath + "toolbar/toolbar_bg_top_dark.svg"
        width: parent.width
    }

    ObjectModel {
        id: probeModel
        source: myHomeModels.objectLinks
        containers: myHomeModels.homepageLinks ? [myHomeModels.homepageLinks.uii] : [Container.IdNoContainer]
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
                defaultImage: homeProperties.skin === HomeProperties.Clear ? imagesPath + "toolbar/icon_home.svg":
                                                                             imagesPath + "toolbar/icon_home_pressed.svg"
                pressedImage: homeProperties.skin === HomeProperties.Clear ? imagesPath + "toolbar/icon_home_pressed.svg":
                                                                             imagesPath + "toolbar/icon_home.svg"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                onTouched: toolbar.homeClicked()
            }
        }

        SvgImage {
            source: imagesPath + "toolbar/toolbar_separator.svg"
            height: toolbar_top.height
        }

        Item {
            width: 99
            height: toolbar_top.height

            ButtonTextImageThreeStates {
                id: date
                defaultImageBg: imagesPath + "toolbar/_bg_date.svg"
                pressedImageBg: imagesPath + "toolbar/_bg_date_pressed.svg"
                textColor: homeProperties.skin === HomeProperties.Clear ? "black":
                                                                          "white"
                pressedTextColor: homeProperties.skin === HomeProperties.Clear ? "white":
                                                                                 "black"
                text: DateTime.format()["date"]
                function setDate(d) {
                    text = DateTime.format(d)["date"]
                }
                onTouched: Stack.goToPage("Settings.qml", {navigationTarget: Navigation.DATE_TIME_SETTINGS})
            }
        }


        SvgImage {
            source: imagesPath + "toolbar/toolbar_separator.svg"
            height: toolbar_top.height
        }

        Item {
            width: 64
            height: toolbar_top.height

            ButtonTextImageThreeStates {
                id: time
                defaultImageBg: imagesPath + "toolbar/_bg_time.svg"
                pressedImageBg: imagesPath + "toolbar/_bg_time_pressed.svg"
                textColor: homeProperties.skin === HomeProperties.Clear ? "black":
                                                                          "white"
                pressedTextColor: homeProperties.skin === HomeProperties.Clear ? "white":
                                                                                 "black"
                text: DateTime.format()["time"]
                function setTime(d) {
                    text = DateTime.format(d)["time"]
                }
                onTouched: Stack.goToPage("Settings.qml", {navigationTarget: Navigation.DATE_TIME_SETTINGS})
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

        Item {
            width: 64
            height: toolbar_top.height
            visible: probeModel.count > 0

            UbuntuLightText {
                id: temperature
                property variant itemObject: probeModel.count > 0 ? probeModel.getObject(0) : undefined
                text: itemObject !== undefined ? (itemObject.btObject.temperature / 10).toFixed(1) + " °C" : ""
                color: homeProperties.skin === HomeProperties.Clear ? "black":
                                                                      "white"
                font.pixelSize: toolbar.fontSize
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    Row {
        id: toolbarRight
        anchors.right: toolbar_top.right
        anchors.verticalCenter: toolbar_top.verticalCenter

        // antintrusion
        ToolbarButton {
            height: toolbar_top.height
            visible: EventManager.eventManager.antintrusionPresent && global.guiSettings.burglarAlarmAlert
            defaultImage: EventManager.eventManager.isAntintrusionInserted ?
                              (homeProperties.skin === HomeProperties.Clear ?
                                   "../images/toolbar/icon_burlgar-alarm-on.svg" :
                                   "../images/toolbar/icon_burlgar-alarm-on_p.svg") :
                              (homeProperties.skin === HomeProperties.Clear ?
                                   "../images/toolbar/icon_alarm-disabled.svg" :
                                   "../images/toolbar/icon_alarm-disabled_p.svg")
            pressedImage:  EventManager.eventManager.isAntintrusionInserted ?
                               (homeProperties.skin === HomeProperties.Clear ?
                                    "../images/toolbar/icon_burlgar-alarm-on_p.svg" :
                                    "../images/toolbar/icon_burlgar-alarm-on.svg") :
                               (homeProperties.skin === HomeProperties.Clear ?
                                    "../images/toolbar/icon_alarm-disabled_p.svg" :
                                    "../images/toolbar/icon_alarm-disabled.svg")
            onTouched: {
                toolbar.toolbarNavigationClicked()
                Stack.goToPage(Script.getTarget(Container.IdAntintrusion))
            }
        }

        // alarm clock
        ToolbarButton {
            height: toolbar_top.height
            visible: EventManager.eventManager.clocks > 0 && global.guiSettings.alarmClockAlert
            defaultImage: homeProperties.skin === HomeProperties.Clear ?
                              "../images/toolbar/icon_alarm-clock.svg" :
                              "../images/toolbar/icon_alarm-clock_p.svg"
            pressedImage: homeProperties.skin === HomeProperties.Clear ?
                              "../images/toolbar/icon_alarm-clock_p.svg" :
                              "../images/toolbar/icon_alarm-clock.svg"
            onTouched: {
                toolbar.toolbarNavigationClicked()
                if (EventManager.eventManager.clockRinging) {
                    // the video camera page expects navigation to be managed in toolbar
                    // let's manage it
                    if (Stack.currentPage()._pageName === "VideoCamera")
                        Stack.popPage()
                    EventManager.eventManager.resendAlarmStarted()
                }
                else {
                    Stack.goToPage("Settings.qml", {"navigationTarget": Navigation.ALARM_CLOCKS})
                }
            }
        }

        // auto open
        ToolbarButton {
            height: toolbar_top.height
            visible: EventManager.eventManager.autoOpen && global.guiSettings.professionalStudioAlert
            defaultImage: homeProperties.skin === HomeProperties.Clear ?
                              "../images/toolbar/icon_vde-auto-open.svg" :
                              "../images/toolbar/icon_vde-auto-open_p.svg"
            pressedImage: homeProperties.skin === HomeProperties.Clear ?
                              "../images/toolbar/icon_vde-auto-open_p.svg" :
                              "../images/toolbar/icon_vde-auto-open.svg"
            onTouched: {
                toolbar.toolbarNavigationClicked()
                Stack.goToPage("Settings.qml", {"navigationTarget": Navigation.AUTO_OPEN})
            }
        }

        // auto answer
        ToolbarButton {
            height: toolbar_top.height
            visible: EventManager.eventManager.handsFree && global.guiSettings.handsFreeAlert
            defaultImage: homeProperties.skin === HomeProperties.Clear ?
                              "../images/toolbar/icon_vde-auto-answer.svg" :
                              "../images/toolbar/icon_vde-auto-answer_p.svg"
            pressedImage: homeProperties.skin === HomeProperties.Clear ?
                              "../images/toolbar/icon_vde-auto-answer_p.svg" :
                              "../images/toolbar/icon_vde-auto-answer.svg"
            onTouched: {
                toolbar.toolbarNavigationClicked()
                Stack.goToPage("Settings.qml", {"navigationTarget": Navigation.HANDS_FREE})
            }
        }

        // vde mute
        ToolbarButton {
            height: toolbar_top.height
            visible: EventManager.eventManager.vdeMute && global.guiSettings.callExclusionAlert
            defaultImage: homeProperties.skin === HomeProperties.Clear ?
                              "../images/toolbar/icon_vde-mute.svg" :
                              "../images/toolbar/icon_vde-mute_p.svg"
            pressedImage: homeProperties.skin === HomeProperties.Clear ?
                              "../images/toolbar/icon_vde-mute_p.svg" :
                              "../images/toolbar/icon_vde-mute.svg"
            onTouched: {
                toolbar.toolbarNavigationClicked()
                Stack.goToPage("Settings.qml", {"navigationTarget": Navigation.VDE_MUTE})
            }
        }

        // vde teleloop
        ToolbarButton {
            height: toolbar_top.height
            visible: EventManager.eventManager.vdeTeleloop
            defaultImage: homeProperties.skin === HomeProperties.Clear ?
                              "../images/toolbar/icon_teleloop.svg" :
                              "../images/toolbar/icon_teleloop_p.svg"
            pressedImage: homeProperties.skin === HomeProperties.Clear ?
                              "../images/toolbar/icon_teleloop_p.svg" :
                              "../images/toolbar/icon_teleloop.svg"
            onTouched: {
                toolbar.toolbarNavigationClicked()
                Stack.goToPage("Settings.qml", {"navigationTarget": Navigation.VDE_TELELOOP})
            }
        }

        // alerts
        ToolbarButton {
            height: toolbar_top.height
            visible: EventManager.eventManager.alarms > 0 && global.guiSettings.burglarAlarmDangerAlert
            quantity: EventManager.eventManager.alarms
            defaultImage: homeProperties.skin === HomeProperties.Clear ?
                              "../images/toolbar/icon_alarm.svg" :
                              "../images/toolbar/icon_alarm_p.svg"
            pressedImage: homeProperties.skin === HomeProperties.Clear ?
                              "../images/toolbar/icon_alarm_p.svg" :
                              "../images/toolbar/icon_alarm.svg"
            onTouched: {
                toolbar.toolbarNavigationClicked()
                Stack.goToPage("Antintrusion.qml", {"navigationTarget": Navigation.ALARM_LOG})
            }
        }

        // play
        ToolbarButton {
            height: toolbar_top.height
            visible: EventManager.eventManager.playing && global.guiSettings.playerAlert
            defaultImage: homeProperties.skin === HomeProperties.Clear ?
                              "../images/toolbar/icon_source-play.svg" :
                              "../images/toolbar/icon_source-play_p.svg"
            pressedImage: homeProperties.skin === HomeProperties.Clear ?
                              "../images/toolbar/icon_source-play_p.svg" :
                              "../images/toolbar/icon_source-play.svg"
            onTouched: {
                toolbar.toolbarNavigationClicked()
                Stack.goToPage("AudioPlayer.qml", {"upnp": global.audioVideoPlayer.isUpnp()})
            }
        }

        // message
        ToolbarButton {
            height: toolbar_top.height
            visible: EventManager.eventManager.messages > 0 && global.guiSettings.messageAlert
            quantity: EventManager.eventManager.messages
            defaultImage: homeProperties.skin === HomeProperties.Clear ?
                              "../images/toolbar/icon_new-message.svg" :
                              "../images/toolbar/icon_new-message_p.svg"
            pressedImage: homeProperties.skin === HomeProperties.Clear ?
                              "../images/toolbar/icon_new-message_p.svg" :
                              "../images/toolbar/icon_new-message.svg"
            onTouched: {
                toolbar.toolbarNavigationClicked()
                Stack.goToPage(Script.getTarget(Container.IdMessages))
            }
        }

        Row {
            id: recording

            height: toolbar_top.height
            visible: EventManager.eventManager.scenarioRecording && global.guiSettings.scenarioRecordingAlert

            // separator
            SvgImage {
                source: "../images/toolbar/toolbar_separator.svg"
                height: toolbar_top.height
            }

            SvgImage {
                source: "../images/toolbar/_bg_alert.svg"

                SvgImage {
                    id: recordingImg

                    source: homeProperties.skin === HomeProperties.Clear ?
                                "../images/toolbar/icon_scenario-recording.svg" :
                                "../images/toolbar/icon_scenario-recording_p.svg"
                    anchors.centerIn: parent

                    Behavior on opacity {
                        NumberAnimation { duration: blinkingTimer.interval }
                    }
                }

                // blinking is managed externally (we still don't have blinking buttons),
                // but it can be a button feature if used more
                Timer {
                    id: blinkingTimer

                    running: recording.visible
                    interval: 500
                    repeat: true
                    onTriggered: recordingImg.opacity === 1 ? recordingImg.opacity = 0 : recordingImg.opacity = 1
                }
            }
        }

        // energy, stop&go danger
        ToolbarButton {
            height: toolbar_top.height
            quantity: EventManager.eventManager.dangers
            defaultImage: homeProperties.skin === HomeProperties.Clear ?
                              "../images/toolbar/icon_energy.svg" :
                              "../images/toolbar/icon_energy_p.svg"
            pressedImage: homeProperties.skin === HomeProperties.Clear ?
                              "../images/toolbar/icon_energy_p.svg" :
                              "../images/toolbar/icon_energy.svg"
            onTouched: {
                toolbar.toolbarNavigationClicked()
                Stack.goToPage("EnergyManagement.qml", {"navigationTarget": Navigation.SUPERVISION})
            }
        }

        // help
        ToolbarButton {
            id: helpToolbarButton

            // fallback url for help system
            property string helpUrl: "localhost"

            height: toolbar_top.height
            visible: true // on ToolbarButton visible property is binded to quantity
            defaultImage: homeProperties.skin === HomeProperties.Clear ?
                              "../images/toolbar/help_online.svg" :
                              "../images/toolbar/help_online_p.svg"
            pressedImage: homeProperties.skin === HomeProperties.Clear ?
                              "../images/toolbar/help_online_p.svg" :
                              "../images/toolbar/help_online.svg"
            onTouched: {
                toolbar.toolbarNavigationClicked()
                Stack.currentPage().processLaunched(global.browser)
                global.browser.displayUrl(helpUrl)
            }
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
