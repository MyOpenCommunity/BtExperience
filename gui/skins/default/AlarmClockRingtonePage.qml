import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Text 1.0
import Components.Settings 1.0

import "js/Stack.js" as Stack

Page {
    id: page

    property variant alarmClock: undefined

    property int currentSourceIdx: -1
    property int currentAmbientIdx: 0
    property int currentAmplifierIdx: -1

    // the following properties are used by delegates
    property variant actualModel: privateProps.currentChoice === 0 ? beepModel : _choicesModel
    // the following properties are state dependant
    property variant _choicesModel: kindModel

    text: qsTr("Alarm settings")
    source : global.guiSettings.homeBgImage

    ListModel {
        id: beepModel
    }

    ObjectModel {
        id: kindModel
        filters: [
            {objectId: ObjectInterface.IdSoundSource}
        ]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    ObjectModel {
        id: ambientModel
        filters: [
            {objectId: ObjectInterface.IdMultiChannelSpecialAmbient},
            {objectId: ObjectInterface.IdMultiChannelSoundAmbient},
            {objectId: ObjectInterface.IdMonoChannelSoundAmbient},
            {objectId: ObjectInterface.IdMultiGeneral},
        ]
    }

    ObjectModel {
        id: amplifierModel
        filters: [
            {objectId: ObjectInterface.IdAmbientAmplifier},
            {objectId: ObjectInterface.IdSoundAmplifierGroup},
            {objectId: ObjectInterface.IdSoundAmplifier},
            {objectId: ObjectInterface.IdPowerAmplifier},
            {objectId: ObjectInterface.IdAmplifierGeneral},
        ]
        containers: [privateProps.ambientUii]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
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

    SvgImage {
        id: verticalSeparator
        source: "images/common/separator_vertical_1x370.svg"
        anchors {
            top: horizontalSeparator.bottom
            topMargin: bg.height / 100 * 1.57
            left: bg.left
            leftMargin: bg.width / 100 * 31.40
        }
    }

    UbuntuMediumText {
        text: qsTr("Alarm signal settings")
        font.pixelSize: 18
        color: "white"
        anchors {
            left: bg.left
            leftMargin: bg.width / 100 * 3.92
            bottom: horizontalSeparator.top
            bottomMargin: bg.height / 100 * 1.57
        }
    }

    // left panel
    UbuntuLightText {
        id: signalText
        text: qsTr("Signal:")
        font.pixelSize: 14
        color: "white"
        anchors {
            left: bg.left
            leftMargin: bg.width / 100 * 3.92
            top: horizontalSeparator.bottom
            topMargin: bg.height / 100 * 1.57
        }
    }

    Column {
        id: choices
        spacing: bg.height / 100 * 2.29
        anchors {
            left: bg.left
            leftMargin: bg.width / 100 * 4.71
            top: signalText.bottom
            topMargin: bg.height / 100 * 1.57
        }
        Repeater {
            model: 2
            delegate: ControlRadioHorizontal {
                width: bg.width / 100 * 23.55
                text: privateProps.getTypeText(index)
                onClicked: privateProps.setStatus(index)
                status: privateProps.getStatus(index, privateProps.dummy)
            }
        }
    }

    UbuntuLightText {
        id: volumeText
        text: qsTr("Volume")
        font.pixelSize: 14
        color: "white"
        anchors {
            left: bg.left
            leftMargin: bg.width / 100 * 3.92
            top: choices.bottom
            topMargin: bg.height / 100 * 3
        }
    }

    ControlSpin {
        id: volumeSpin
        text: page.alarmClock.volume + qsTr("%")
        anchors {
            left: bg.left
            leftMargin: bg.width / 100 * 3.92
            top: volumeText.bottom
            topMargin: bg.height / 100 * 1.57
        }
        onMinusClicked: page.alarmClock.decrementVolume()
        onPlusClicked: page.alarmClock.incrementVolume()
    }

    // upper-right panel
    UbuntuLightText {
        id: sourceText
        text: privateProps.currentChoice === 0 ? "" : qsTr("Select a source:")
        font.pixelSize: 14
        color: "white"
        anchors {
            left: verticalSeparator.left
            leftMargin: bg.width / 100 * 3.92
            top: horizontalSeparator.bottom
            topMargin: bg.height / 100 * 2
        }
    }

    ButtonImageThreeStates {
        id: leftAmbient

        visible: privateProps.currentChoice === 1
        opacity: 0
        defaultImageBg: "images/common/button_pager.svg"
        pressedImageBg: "images/common/button_pager_press.svg"
        shadowImage: "images/common/shadow_button_pager.svg"
        defaultImage: "images/common/icon_pager_arrow_prev.svg"
        pressedImage: "images/common/icon_pager_arrow_prev_p.svg"
        anchors {
            left: verticalSeparator.left
            leftMargin: bg.width / 100 * 3.92
            top: sourceText.bottom
            topMargin: bg.height / 100 * 2
        }
        onClicked: {
            if (page.currentAmbientIdx > 0) {
                page.currentAmplifierIdx = -1
                page.currentAmbientIdx -= 1
            }
        }
    }

    UbuntuLightText {
        id: ambientText

        visible: privateProps.currentChoice === 1
        opacity: 0
        text: ambientModel.getObject(page.currentAmbientIdx).name
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 14
        color: "white"
        anchors {
            left: leftAmbient.right
            right: rightAmbient.left
            top: sourceText.bottom
            topMargin: bg.height / 100 * 2
        }
    }

    ButtonImageThreeStates {
        id: rightAmbient

        visible: privateProps.currentChoice === 1
        opacity: 0
        defaultImageBg: "images/common/button_pager.svg"
        pressedImageBg: "images/common/button_pager_press.svg"
        shadowImage: "images/common/shadow_button_pager.svg"
        defaultImage: "images/common/icon_pager_arrow.svg"
        pressedImage: "images/common/icon_pager_arrow_p.svg"
        anchors {
            right: pageChanger.left
            rightMargin: bg.width / 100 * 3.92
            top: sourceText.bottom
            topMargin: bg.height / 100 * 2
        }
        onClicked: {
            if (page.currentAmbientIdx < ambientModel.count - 1) {
                page.currentAmplifierIdx = -1
                page.currentAmbientIdx += 1
            }
        }
    }

    PaginatorOnBackground {
        id: paginator

        elementsOnPage: 9
        buttonVisible: false
        spacing: 5
        anchors {
            top: ambientText.bottom
            topMargin: bg.height / 100 * 5
            left: verticalSeparator.left
            leftMargin: bg.width / 100 * 3.92
            right: verticalSeparator.right
            bottom: bg.bottom
            bottomMargin: bg.width / 100 * 4.58
        }
        onCurrentPageChanged: {
            page.currentSourceIdx = -1
            page.currentAmplifierIdx = -1
        }
        model: page.actualModel
        delegate: Item {
            width: delegateRadio.width
            height: delegateRadio.height + bg.height / 100 * 2.29 // adds spacing

            ControlRadioHorizontal {
                id: delegateRadio

                property variant itemObject: page.actualModel.getObject(index)

                width: bg.width / 100 * 40
                text: delegateRadio.itemObject === undefined ? "" : delegateRadio.itemObject.name
                onClicked: {
                    if (page.state === "")
                        page.currentSourceIdx = index
                    else
                        page.currentAmplifierIdx = index
                }
                status: (page.state === "" && page.currentSourceIdx === index) ||
                        (page.state === "amplifiers" && page.currentAmplifierIdx === index)
            }
        }
    }

    ButtonThreeStates {
        id: pageChanger

        visible: privateProps.currentChoice === 1
        defaultImage: "images/common/alarm_clock/freccia_dx.svg"
        pressedImage: "images/common/alarm_clock/freccia_dx_P.svg"
        anchors {
            top: horizontalSeparator.bottom
            topMargin: bg.height / 100 * 5.72
            right: bg.right
            rightMargin: bg.width / 100 * 3.92
        }
        onClicked:page.state = page.state === "" ? "amplifiers" : ""
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
        font.pixelSize: 14
        color: "white"
        anchors {
            verticalCenter: bottomBg.verticalCenter
            right: okButton.left
            rightMargin: bg.width / 100 * 1.10
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
        onClicked: {
            page.alarmClock.alarmType = (privateProps.currentChoice === 0 ? AlarmClock.AlarmClockBeep : AlarmClock.AlarmClockSoundSystem)
            if (page.currentSourceIdx >= 0)
                page.alarmClock.source = kindModel.getObject(page.currentSourceIdx)
            if (page.currentAmplifierIdx >= 0)
                page.alarmClock.setAmplifierFromQObject(amplifierModel.getObject(page.currentAmplifierIdx))
            page.alarmClock.apply()
            Stack.popPage()
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
        onClicked: {
            page.alarmClock.reset()
            Stack.popPage()
        }
    }

    states: [
        State {
            name: "amplifiers"
            PropertyChanges {
                target: pageChanger
                defaultImage: "images/common/alarm_clock/freccia_sx.svg"
                pressedImage: "images/common/alarm_clock/freccia_sx_P.svg"
            }
            PropertyChanges {
                target: page
                _choicesModel: amplifierModel
            }
            PropertyChanges {
                target: ambientText
                opacity: 1
            }
            PropertyChanges {
                target: leftAmbient
                opacity: 1
            }
            PropertyChanges {
                target: rightAmbient
                opacity: 1
            }
        }
    ]

    transitions: [
        Transition {
            ParallelAnimation {
                NumberAnimation { property: "opacity"; duration: 400 }
                AnchorAnimation { duration: 400 }
            }
        }
    ]

    QtObject {
        id: privateProps

        property int currentChoice: 0

        property bool dummy: false // this is only to trigger updates on all radios

        property bool beepStatus: true
        property bool soundDiffusionStatus: false
        property int ambientUii: ambientModel.getObject(page.currentAmbientIdx).uii

        function getStatus(kind, dummy) {
            if (kind === 0)
                return privateProps.beepStatus
            if (kind === 1)
                return privateProps.soundDiffusionStatus
            return false
        }

        function setStatus(kind) {
            if (privateProps.currentChoice === kind)
                return

            privateProps.dummy = !privateProps.dummy // triggers updates
            privateProps.beepStatus = false
            privateProps.soundDiffusionStatus = false

            privateProps.currentChoice = kind
            page.currentSourceIdx = -1
            page.currentAmplifierIdx = -1
            page.currentAmbientIdx = 0
            if (kind === 0)
                page.state = ""

            if (kind === 0)
                privateProps.beepStatus = true
            if (kind === 1)
                privateProps.soundDiffusionStatus = true

            paginator.currentPage = 1
        }

        function getTypeText(kind) {
            if (kind === 0)
                return qsTr("beep")
            if (kind === 1)
                return qsTr("sound diffusion")
            return " " // a space to avoid zero height text element
        }
    }
}
