import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Text 1.0
import Components.Settings 1.0

import "js/Stack.js" as Stack

Page {
    id: page

    property variant alarmClock: undefined
    property int currentLink: -1

    // the following properties are used by delegates
    property variant actualModel: privateProps.currentChoice === 0 ? beepModel : kindModel

    text: qsTr("Alarm settings")
    source: "images/profiles.jpg"

    ListModel {
        id: beepModel
    }

    ListModel {
        id: kindModel

        function getObject(index) {
            return get(index)
        }

        Component.onCompleted: {
            kindModel.append({"name": qsTr("aux")})
            kindModel.append({"name": qsTr("radio")})
            kindModel.append({"name": qsTr("radio ip")})
            kindModel.append({"name": qsTr("sd")})
            kindModel.append({"name": qsTr("usb")})
        }
    }

//    MediaModel {
//        id: soundDiffusionModel
//        source: myHomeModels.mediaLinks
//        containers: [-1] // not assigned yet
//        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
//    }

//    ObjectModel {
//        id: beepModel
//        filters: [
//            {objectId: ObjectInterface.IdExternalPlace},
//            {objectId: ObjectInterface.IdSurveillanceCamera}
//        ]
//        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
//    }

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
            topMargin: bg.height / 100 * 1.57
        }
    }

    PaginatorOnBackground {
        id: paginator

        elementsOnPage: 9
        buttonVisible: false
        spacing: 5
        anchors {
            top: sourceText.bottom
            topMargin: bg.height / 100 * 1.57
            left: verticalSeparator.left
            leftMargin: bg.width / 100 * 3.92
            right: verticalSeparator.right
            bottom: bg.bottom
            bottomMargin: bg.width / 100 * 4.58
        }
        onCurrentPageChanged: page.currentLink = -1
        model: page.actualModel
        delegate: Item {
            width: delegateRadio.width
            height: delegateRadio.height + bg.height / 100 * 2.29 // adds spacing

            ControlRadioHorizontal {
                id: delegateRadio

                property variant itemObject: page.actualModel.getObject(index)

                width: bg.width / 100 * 54.95
                text: delegateRadio.itemObject === undefined ? "" : delegateRadio.itemObject.name
                onClicked: page.currentLink = index
                status: page.currentLink === index
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
            console.log("_______________________ onClicked ___________________________")
            console.log("save data!!!")
//            if (page.currentLink >= 0) {
//                // saves selection on current profile
//                var current = page.actualModel.getObject(page.currentLink)

//                var name = ""
//                if (current.name)
//                    name = current.name
//                var address = ""
//                if (current.address)
//                    address = current.address
//                var btObject = current
//                var x = -1
//                var y = -1
//                var media = privateProps.getTypeText(privateProps.currentChoice)

//                soundDiffusionModel.append(myHomeModels.createQuicklink(page.profile.uii, media, name, address, btObject, x, y))
//            }
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

    QtObject {
        id: privateProps

        property int currentChoice: 0

        property bool dummy: false // this is only to trigger updates on all radios

        property bool beepStatus: true
        property bool soundDiffusionStatus: false

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
