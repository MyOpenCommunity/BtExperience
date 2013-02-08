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

    // the following properties are used by delegates
    property variant actualModel: page.alarmClock.alarmType === AlarmClock.AlarmClockBeep ?
                                      beepModel :
                                      (page.state === "" ?
                                           sourceModel :
                                           amplifierModel)

    text: qsTr("Alarm settings")
    source : homeProperties.homeBgImage

    Component.onDestruction: page.alarmClock.reset()

    Component {
        id: errorFeedback
        FeedbackPopup {
            text: ""
            isOk: false
        }
    }

    ListModel {
        id: beepModel
    }

    SystemsModel { id: modelIdSoundDiffusionMulti; systemId: Container.IdSoundDiffusionMulti }
    SystemsModel { id: modelIdSoundDiffusionMono; systemId: Container.IdSoundDiffusionMono }

    ObjectModel {
        id: soundDiffusionModel
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
        containers: [modelIdSoundDiffusionMulti.systemUii, modelIdSoundDiffusionMono.systemUii]
    }

    ObjectModel {
        id: sourceModel
        filters: [
            {objectId: ObjectInterface.IdSoundSource, objectKey: SourceObject.RdsRadio },
            {objectId: ObjectInterface.IdSoundSource, objectKey: SourceObject.IpRadio },
            {objectId: ObjectInterface.IdSoundSource, objectKey: SourceObject.Aux },
            {objectId: ObjectInterface.IdSoundSource, objectKey: SourceObject.Sd },
            {objectId: ObjectInterface.IdSoundSource, objectKey: SourceObject.Usb }
        ]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
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
        containers: [page.alarmClock.ambient === null ? -1 : page.alarmClock.ambient.uii]
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
        text: qsTr("Alarm clock - sound settings")
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
        font.pixelSize: 16
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
        spacing: bg.height / 100 * 5
        anchors {
            left: bg.left
            leftMargin: bg.width / 100 * 4.71
            top: signalText.bottom
            topMargin: bg.height / 100 * 5
        }
        Repeater {
            model: 2
            delegate: ControlRadioHorizontal {
                width: bg.width / 100 * 23.55
                text: privateProps.getTypeText(index)
                pixelSize: 16
                onClicked: privateProps.setAlarmType(index)
                status: index === page.alarmClock.alarmType
                visible: privateProps.getTypeVisible(index, soundDiffusionModel.count)
            }
        }
    }

    UbuntuLightText {
        id: volumeText
        text: qsTr("Volume")
        visible: soundDiffusionModel.count > 0
        font.pixelSize: 16
        color: "white"
        anchors {
            left: bg.left
            leftMargin: bg.width / 100 * 3.92
            top: choices.bottom
            topMargin: bg.height / 100 * 6
        }
    }

    ControlSpin {
        id: volumeSpin
        text: page.alarmClock.volume + "%"
        visible: soundDiffusionModel.count > 0
        anchors {
            horizontalCenter: choices.horizontalCenter
            top: volumeText.bottom
            topMargin: bg.height / 100 * 2
        }
        onMinusClicked: page.alarmClock.decrementVolume()
        onPlusClicked: page.alarmClock.incrementVolume()
    }

    // upper-right panel
    UbuntuLightText {
        id: sourceText
        text: page.alarmClock.alarmType === AlarmClock.AlarmClockBeep ?
                  "" :
                  page.state === "" ?
                      qsTr("Select a source:") :
                      qsTr("Select an amplifier:")
        visible: soundDiffusionModel.count > 0
        font.pixelSize: 16
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

        visible: page.alarmClock.alarmType === AlarmClock.AlarmClockSoundSystem &&
                 soundDiffusionModel.count > 0
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
        onClicked: page.alarmClock.decrementAmbient()
    }

    Item {
        id: ambientTextItem

        anchors {
            top: leftAmbient.top
            bottom: leftAmbient.bottom
            left: leftAmbient.right
            right: rightAmbient.left
        }

        UbuntuLightText {
            id: ambientText

            visible: page.alarmClock.alarmType === AlarmClock.AlarmClockSoundSystem &&
                     soundDiffusionModel.count > 0
            opacity: 0
            text: page.alarmClock.ambient ? page.alarmClock.ambient.name : ""
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 16
            color: "white"
            anchors.centerIn: parent
        }
    }

    ButtonImageThreeStates {
        id: rightAmbient

        visible: page.alarmClock.alarmType === AlarmClock.AlarmClockSoundSystem &&
                 soundDiffusionModel.count > 0
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
        onClicked: page.alarmClock.incrementAmbient()
    }

    PaginatorOnBackground {
        id: paginator

        visible: soundDiffusionModel.count > 0
        elementsOnPage: 7
        itemSpacing: 9
        anchors {
            top: ambientTextItem.bottom
            topMargin: bg.height / 100 * 5
            left: verticalSeparator.left
            leftMargin: bg.width / 100 * 3.92
            right: verticalSeparator.right
            bottom: bg.bottom
            bottomMargin: bg.width / 100 * 4.58
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
                pixelSize: 16
                onClicked: {
                    if (page.state === "")
                        page.alarmClock.source = itemObject
                    else
                        page.alarmClock.amplifier = itemObject
                }
                status: (page.state === "" && page.alarmClock.source === itemObject) ||
                        (page.state === "amplifiers" && page.alarmClock.amplifier === itemObject)
            }
        }
    }

    ButtonThreeStates {
        id: pageChanger

        visible: page.alarmClock.alarmType === AlarmClock.AlarmClockSoundSystem &&
                 soundDiffusionModel.count > 0
        defaultImage: "images/common/alarm_clock/freccia_dx.svg"
        pressedImage: "images/common/freccia_dx_P.svg"
        anchors {
            top: horizontalSeparator.bottom
            topMargin: bg.height / 100 * 5.72
            right: bg.right
            rightMargin: bg.width / 100 * 3.92
        }
        onClicked: page.state = page.state === "" ? "amplifiers" : ""
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
        onClicked: {
            var r = page.alarmClock.validityStatus

            if (r === AlarmClock.AlarmClockApplyResultNoAmplifier) {
                page.installPopup(errorFeedback, { text: qsTr("No amplifier set") })
                return
            }
            else if (r === AlarmClock.AlarmClockApplyResultNoSource) {
                page.installPopup(errorFeedback, { text: qsTr("No source set") })
                return
            }

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
        onClicked: Stack.popPage()
    }

    states: [
        State {
            name: "amplifiers"
            PropertyChanges {
                target: pageChanger
                defaultImage: "images/common/alarm_clock/freccia_sx.svg"
                pressedImage: "images/common/freccia_sx_P.svg"
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

        function setAlarmType(t) {
            if (t === 0)
                page.alarmClock.alarmType = AlarmClock.AlarmClockBeep
            else if (t === 1)
                page.alarmClock.alarmType = AlarmClock.AlarmClockSoundSystem
        }

        function getTypeText(kind) {
            if (kind === 0)
                return qsTr("beep")
            if (kind === 1)
                return qsTr("sound diffusion")
            return " " // a space to avoid zero height text element
        }

        function getTypeVisible(kind, count) {
            if (kind === 0)
                return true
            if (kind === 1)
                return count > 0
            return false
        }
    }
}
