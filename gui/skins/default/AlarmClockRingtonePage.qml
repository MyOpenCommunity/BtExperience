import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Popup 1.0
import Components.Text 1.0
import Components.Settings 1.0
import "js/Stack.js" as Stack


/**
  \ingroup Core

  \brief Page to set alarm clock ringtone.

  This page contains the logic to set the ringtone for an alarm clock.
  On the left panel, the user may change the type of ringtone (simple beep or
  sound diffusion alarm) and the alarm volume.

  The right panel is used to customize the sound diffusion alarm. In it, the
  user may choose one of the available sources. Clicking on the page changer,
  the user can switch between sources and amplifiers. In the amplifiers screen
  the user sets the amplifier that will diffuse the alarm when triggering.
  Amplifier are grouped by ambient.
  */
Page {
    id: page

    /** the alarm clock to be modified */
    property variant alarmClock: undefined

    // the following properties are used by delegates
    property variant actualModel: page.alarmClock.alarmType === AlarmClock.AlarmClockBeep ?
                                      beepModel :
                                      (page.state === "" ?
                                           sourceModel :
                                           outputModel)

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
            {objectId: ObjectInterface.IdAmplifierGeneral}
        ]
    }

    ObjectModel {
        id: ambientModel
        filters: [
            {objectId: ObjectInterface.IdMultiChannelSpecialAmbient},
            {objectId: ObjectInterface.IdMultiChannelSoundAmbient},
            {objectId: ObjectInterface.IdMonoChannelSoundAmbient},
            {objectId: ObjectInterface.IdMultiGeneral}
        ]
    }

    ObjectModelSource {
        id: outputModelSource
    }

    Component.onCompleted: {
        var idx = 0 // index of element to append
        for (var i = 0; i < ambientModel.count; ++i) {
            var amb = ambientModel.getObject(i)
            // filters amplifiers by ambient
            amplifierModel.containers = [amb.uii]
            var amplifierCount = amplifierModel.count
            if (amplifierCount === 0) // no ampli in this ambient, skips
                continue
            // if ambient is last page element, adds a spacer to make ambient
            // visible on next page
            if (idx % paginator.elementsOnPage === paginator.elementsOnPage - 1)
                outputModelSource.appendEmpty()
            outputModelSource.append(amb) // adds ambient to list
            ++idx
            for (var j = 0; j < amplifierCount; ++j) {
                outputModelSource.append(amplifierModel.getObject(j)) // adds ampli to list
                ++idx
            }
        }
    }

    ObjectModel {
        id: outputModel
        source: outputModelSource.model
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
                onPressed: privateProps.setAlarmType(index)
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
            left: paginator.left
            top: horizontalSeparator.bottom
            topMargin: bg.height / 100 * 2
        }
    }

    PaginatorOnBackground {
        id: paginator

        visible: soundDiffusionModel.count > 0
        elementsOnPage: 6
        itemSpacing: 25
        anchors {
            top: sourceText.bottom
            topMargin: bg.height / 100 * 5
            bottom: bg.bottom
            bottomMargin: bg.height / 100 * 2.92
            left: verticalSeparator.right
            leftMargin: bg.width / 100 * 3.92
        }
        model: page.actualModel

        delegate: paginatorDelegate
    }

    Component {
        id: paginatorDelegate

        Item {
            id: paginatorItem

            property variant itemObject: page.actualModel.getObject(index)

            width: bg.width / 100 * 40
            height: bg.height / 100 * 5.72

            function bestDelegate(type) {
                switch(type) {
                case "":
                    return sourceDelegate
                case "amplifiers":
                    if (itemObject.objectId === ObjectInterface.IdEmptyObject)
                        return spacerDelegate
                    else if (itemObject.objectId === ObjectInterface.IdAmbientAmplifier ||
                             itemObject.objectId === ObjectInterface.IdSoundAmplifierGroup ||
                             itemObject.objectId === ObjectInterface.IdSoundAmplifier ||
                             itemObject.objectId === ObjectInterface.IdPowerAmplifier ||
                             itemObject.objectId === ObjectInterface.IdAmplifierGeneral)
                        return amplifierDelegate
                    else if (itemObject.objectId === ObjectInterface.IdMultiChannelSpecialAmbient ||
                             itemObject.objectId === ObjectInterface.IdMultiChannelSoundAmbient ||
                             itemObject.objectId === ObjectInterface.IdMonoChannelSoundAmbient ||
                             itemObject.objectId === ObjectInterface.IdMultiGeneral)
                        return ambientDelegate
                    else
                        console.log("Unknown delegate id: " + itemObject.objectId + " " + itemObject)
                }
            }

            Loader {
                id: paginatorLoader

                sourceComponent: bestDelegate(page.state)
                anchors.centerIn: paginatorItem
                z: 1
                onLoaded: item.itemObject = paginatorItem.itemObject
            }
        }
    }

    Component {
        id: sourceDelegate

        ControlRadioHorizontal {
            property variant itemObject

            width: bg.width / 100 * 40
            height: bg.height / 100 * 5.72
            text: itemObject === undefined ? "" : itemObject.name
            pixelSize: 16
            onPressed: page.alarmClock.source = itemObject
            status: page.alarmClock.source === itemObject
        }
    }

    Component {
        id: amplifierDelegate

        ControlRadioHorizontal {
            property variant itemObject

            width: bg.width / 100 * 40
            height: bg.height / 100 * 5.72
            text: itemObject === undefined ? "" : itemObject.name
            pixelSize: 16
            onPressed: page.alarmClock.amplifier = itemObject
            status: page.alarmClock.amplifier === itemObject
        }
    }

    Component {
        id: ambientDelegate

        UbuntuMediumText {
            property variant itemObject

            width: bg.width / 100 * 40
            height: bg.height / 100 * 5.72
            text: itemObject === undefined ? "" : itemObject.name
            font.pixelSize: 16
            elide: Text.ElideMiddle
        }
    }

    Component {
        id: spacerDelegate

        UbuntuLightText {
            property variant itemObject

            width: bg.width / 100 * 40
            height: bg.height / 100 * 5.72
            text: " "
            font.pixelSize: 16
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
            left: undefined
            leftMargin: 0
            right: bg.right
            rightMargin: bg.width / 100 * 7.84
        }
        onPressed: page.state = page.state === "" ? "amplifiers" : ""
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
        onPressed: Stack.popPage()
    }

    states: [
        State {
            name: "amplifiers"
            PropertyChanges {
                target: pageChanger
                defaultImage: "images/common/alarm_clock/freccia_sx.svg"
                pressedImage: "images/common/freccia_sx_P.svg"
                anchors.leftMargin: bg.width / 100 * 3.92
                anchors.rightMargin: 0
            }
            AnchorChanges {
                target: pageChanger
                anchors.left: verticalSeparator.right
                anchors.right: undefined
            }
            AnchorChanges {
                target: paginator
                anchors.left: pageChanger.right
            }
            StateChangeScript {
                name: "selectAmplifier"
                script: {
                    var absIndex = outputModel.getAbsoluteIndexOf(page.alarmClock.amplifier)
                    if (absIndex !== -1)
                        paginator.openDelegate(absIndex, privateProps.dummy)
                }
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

        function dummy(itemObject) {
            return ""
        }
    }
}
