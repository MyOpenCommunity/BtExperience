import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Popup 1.0
import Components.Text 1.0
import Components.Settings 1.0

import "js/Stack.js" as Stack


Page {
    id: page

    property variant alarmClock: undefined
    property bool isNewAlarm: false

    text: qsTr("Alarm settings")
    source : homeProperties.homeBgImage

    Component.onDestruction: if (page.alarmClock) page.alarmClock.reset()

    ObjectModel {
        id: objectModel
        filters: [{objectId: ObjectInterface.IdAlarmClock}]
    }

    Component {
        id: errorFeedback
        FeedbackPopup {
            isOk: false
        }
    }

    SvgImage {
        id: bg
        source: "images/common/bg_settings_637x437.svg"
        anchors {
            horizontalCenter: bottomBg.horizontalCenter
            bottom: bottomBg.top
            bottomMargin: bg.height / 100 * 2.29
        }
    }

    SvgImage {
        id: horizontalSeparator
        source: "images/common/separator_horizontal_590x1.svg"
        anchors {
            horizontalCenter: bg.horizontalCenter
            top: bg.top
            topMargin: bg.height / 100 * 10.30
        }
    }

    UbuntuMediumText {
        text: qsTr("Alarm clock - date and time")
        font.pixelSize: 18
        color: "white"
        anchors {
            left: bg.left
            leftMargin: bg.width / 100 * 3.92
            bottom: horizontalSeparator.top
            bottomMargin: bg.height / 100 * 1.57
        }
    }

    // middle panel
    Row {
        anchors {
            top: horizontalSeparator.bottom
            topMargin: bg.width / 100 * 3.92
            left: bg.left
            right: bg.right
            bottom: bottomBg.top
        }

        Item { // a spacer
            height: 1
            width: bg.width / 100 * 3.92
        }

        Column {
            id: dateTimePanel

            spacing: 10

            UbuntuMediumText {
                text: qsTr("activation")
                font.pixelSize: 18
                color: "white"
            }

            SvgImage {
                id: line
                source: "images/common/linea.svg"
                width: parent.width
            }

            UbuntuLightText {
                text: qsTr("days")
                font.pixelSize: 16
                color: "white"
            }

            Row {
                spacing: 20
                height: childrenRect.height

                Repeater {
                    model: 7

                    ControlRadio {
                        text: privateProps.getDay(index)
                        pixelSize: 16
                        onClicked: privateProps.setStatus(index)
                        status: privateProps.getStatus(index, privateProps.dummy)
                    }
                }
            }

            Item { // a spacer
                height: 20
                width: line.width
            }

            ControlRadioHorizontal {
                width: parent.width * 0.70
                text: qsTr("Only once")
                pixelSize: 16
                onClicked: privateProps.setStatus()
                status: page.alarmClock.trigger === 0
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Item { // a spacer
                height: 10
                width: line.width
            }

            Column {
                anchors.horizontalCenter: parent.horizontalCenter

                spacing: 10

                UbuntuLightText {
                    text: qsTr("time")
                    font.pixelSize: 16
                    color: "white"
                }

                ControlDateTime {
                    itemObject: page.alarmClock
                    twoFields: true
                }
            }
        }

        Item { // a spacer
            height: 1
            width: bg.width / 100 * 10
        }

        Column {
            id: namePanel

            spacing: 10

            UbuntuMediumText {
                text: qsTr("description")
                font.pixelSize: 18
                color: "white"
            }

            SvgImage {
                source: "images/common/linea.svg"
                width: 230
            }

            SvgImage {
                id: nameBgImage

                source: "images/common/bg_orario.svg"
                width: 230

                UbuntuLightText {
                    id: nameText
                    text: page.alarmClock.description
                    font.pixelSize: 16
                    color: "#5A5A5A"
                    elide: Text.ElideMiddle
                    anchors {
                        left: nameBgImage.left
                        leftMargin: bg.width / 100 * 1.5
                        right: nameBgImage.right
                        rightMargin: bg.width / 100 * 1.5
                        verticalCenter: nameBgImage.verticalCenter
                    }
                }

                BeepingMouseArea {
                    anchors.fill: nameBgImage
                    onClicked: installPopup(popupEditName)
                }
            }
        }
    }

    Component {
        id: popupEditName
        FavoriteEditPopup {
            title: qsTr("Edit alarm name")
            topInputLabel: qsTr("New name:")
            topInputText: page.alarmClock.description
            bottomVisible: false

            function okClicked() {
                page.alarmClock.description = topInputText
            }
        }
    }

    // bottom bar
    SvgImage {
        id: bottomBg
        source: "images/common/bg_settings_637x51.svg"
        anchors {
            horizontalCenter: parent.horizontalCenter
            horizontalCenterOffset: navigationBar.width / 2
            bottom: parent.bottom
            bottomMargin: bg.height / 100 * 2.29
        }
    }

    UbuntuLightText {
        text: qsTr("Save changes?")
        font.pixelSize: 15
        color: "white"
        anchors {
            verticalCenter: bottomBg.verticalCenter
            right: okButton.left
            rightMargin: bg.width / 100 * 4.00
        }
    }

    ButtonThreeStates {
        id: okButton

        defaultImage: "images/common/btn_99x35.svg"
        pressedImage: "images/common/btn_99x35_P.svg"
        selectedImage: "images/common/btn_99x35_S.svg"
        shadowImage: "images/common/btn_shadow_99x35.svg"
        text: qsTr("OK")
        font.pixelSize: 14
        anchors {
            verticalCenter: bottomBg.verticalCenter
            right: cancelButton.left
        }
        onPressed: {
            var r = page.alarmClock.validityStatus

            if (r === AlarmClock.AlarmClockApplyResultNoName) {
                page.installPopup(errorFeedback, { text: qsTr("No name set") })
                return
            }

            page.alarmClock.apply()
            Stack.popPage()
        }
    }

    Component {
        id: cancelFeedback
        FeedbackPopup {
            isOk: false
            onClosePopup: Stack.popPage()
        }
    }

    ButtonThreeStates {
        id: cancelButton

        defaultImage: "images/common/btn_99x35.svg"
        pressedImage: "images/common/btn_99x35_P.svg"
        selectedImage: "images/common/btn_99x35_S.svg"
        shadowImage: "images/common/btn_shadow_99x35.svg"
        text: qsTr("CANCEL")
        font.pixelSize: 14
        anchors {
            verticalCenter: bottomBg.verticalCenter
            right: bottomBg.right
            rightMargin: bg.width / 100 * 1.10
        }
        onPressed: {
            if (isNewAlarm) {
                objectModel.remove(alarmClock)
                page.installPopup(cancelFeedback, { text: qsTr("Alarm not saved") })
                return
            }
            Stack.popPage()
        }
    }

    QtObject {
        id: privateProps

        property bool dummy: false // used to trigger updates

        function getDay(index) {
            var days = qsTr("MTWTFSS")
            return days[index]
        }

        function setStatus(index) {
            if (index === 0)
                page.alarmClock.triggerOnMondays = !page.alarmClock.triggerOnMondays
            else if (index === 1)
                page.alarmClock.triggerOnTuesdays = !page.alarmClock.triggerOnTuesdays
            else if (index === 2)
                page.alarmClock.triggerOnWednesdays = !page.alarmClock.triggerOnWednesdays
            else if (index === 3)
                page.alarmClock.triggerOnThursdays = !page.alarmClock.triggerOnThursdays
            else if (index === 4)
                page.alarmClock.triggerOnFridays = !page.alarmClock.triggerOnFridays
            else if (index === 5)
                page.alarmClock.triggerOnSaturdays = !page.alarmClock.triggerOnSaturdays
            else if (index === 6)
                page.alarmClock.triggerOnSundays = !page.alarmClock.triggerOnSundays
            else {
                page.alarmClock.triggerOnMondays = false
                page.alarmClock.triggerOnTuesdays = false
                page.alarmClock.triggerOnWednesdays = false
                page.alarmClock.triggerOnThursdays = false
                page.alarmClock.triggerOnFridays = false
                page.alarmClock.triggerOnSaturdays = false
                page.alarmClock.triggerOnSundays = false
            }

            privateProps.dummy = !privateProps.dummy // triggers updates
        }

        function getStatus(index, dummy) {
            if (index === 0)
                return page.alarmClock.triggerOnMondays
            else if (index === 1)
                return page.alarmClock.triggerOnTuesdays
            else if (index === 2)
                return page.alarmClock.triggerOnWednesdays
            else if (index === 3)
                return page.alarmClock.triggerOnThursdays
            else if (index === 4)
                return page.alarmClock.triggerOnFridays
            else if (index === 5)
                return page.alarmClock.triggerOnSaturdays
            else if (index === 6)
                return page.alarmClock.triggerOnSundays
        }
    }
}
