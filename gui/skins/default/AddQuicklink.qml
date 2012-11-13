import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Text 1.0
import Components.Settings 1.0

import "js/Stack.js" as Stack

Page {
    id: page

    property variant profile: undefined
    property int currentLink: -1

    // the following properties are used by delegates
    property variant actualModel: privateProps.currentChoice === 0 ? camerasModel : quicklinksModel
    property bool isRemovable: privateProps.currentChoice !== 0

    text: page.profile === undefined ? qsTr("Profiles") : profile.description
    source: page.profile === undefined ? "images/profiles.jpg" : "images/profiles.jpg" // TODO profile background image

    SystemsModel { id: linksModel; systemId: privateProps.getContainerUii(privateProps.currentChoice, privateProps.dummy); source: myHomeModels.mediaContainers }

    MediaModel {
        id: quicklinksModel
        source: myHomeModels.mediaLinks
        containers: [linksModel.systemUii]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    ObjectModel {
        id: camerasModel
        filters: [
            {objectId: ObjectInterface.IdExternalPlace},
            {objectId: ObjectInterface.IdSurveillanceCamera}
        ]
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
        text: qsTr("Add quicklink")
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
        text: qsTr("Type:")
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
            top: linkBgImage.top
            topMargin: bg.height / 100 * 2.29
        }
        Repeater {
            model: 6
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
        id: addTextText
        text: privateProps.getAddText(privateProps.currentChoice)
        font.pixelSize: 14
        color: "white"
        anchors {
            left: verticalSeparator.left
            leftMargin: bg.width / 100 * 3.92
            top: horizontalSeparator.bottom
            topMargin: bg.height / 100 * 1.57
        }
    }

    SvgImage {
        id: linkBgImage
        source: "images/common/bg_text-input.svg"
        anchors {
            left: verticalSeparator.left
            leftMargin: bg.width / 100 * 3.92
            top: addTextText.bottom
            topMargin: bg.height / 100 * 2.29
        }
    }

    UbuntuLightText {
        id: linkText
        text: qsTr("Click to enter link...")
        font.pixelSize: 14
        color: "#5A5A5A"
        anchors {
            left: linkBgImage.left
            leftMargin: bg.width / 100 * 3.92
            verticalCenter: linkBgImage.verticalCenter
        }
    }

    BeepingMouseArea {
        anchors.fill: linkBgImage
        onClicked: installPopup(popupEditLink)
    }

    SvgImage {
        id: nameBgImage
        source: "images/common/bg_text-input.svg"
        anchors {
            left: verticalSeparator.left
            leftMargin: bg.width / 100 * 3.92
            top: linkBgImage.bottom
            topMargin: bg.height / 100 * 2.29
        }
    }

    UbuntuLightText {
        id: nameText
        text: qsTr("Click to enter name...")
        font.pixelSize: 14
        color: "#5A5A5A"
        anchors {
            left: nameBgImage.left
            leftMargin: bg.width / 100 * 3.92
            verticalCenter: nameBgImage.verticalCenter
        }
    }

    BeepingMouseArea {
        anchors.fill: nameBgImage
        onClicked: installPopup(popupEditName)
    }

    ButtonThreeStates {
        id: addButton

        defaultImage: "images/common/btn_add.svg"
        pressedImage: "images/common/btn_add_P.svg"
        shadowImage: "images/common/ombra_btn_add.svg"
        text: qsTr("ADD")
        font.pixelSize: 14

        anchors {
            left: verticalSeparator.left
            leftMargin: bg.width / 100 * 3.92
            top: nameBgImage.bottom
            topMargin: bg.height / 100 * 2.29
        }
        onClicked: {
            myHomeModels.createQuicklink(-1, privateProps.getTypeText(privateProps.currentChoice), nameText.text, linkText.text)
            page.currentLink = 0 // selects first quicklink (the one just created)
        }
    }

    SvgImage {
        id: horizontalRightSeparator
        source: "images/common/separator_horizontal_590x1.svg"
        anchors {
            left: verticalSeparator.left
            leftMargin: bg.width / 100 * 3.92
            right: nameBgImage.right
            top: addButton.bottom
            topMargin: bg.height / 100 * 4.58
        }
    }

    UbuntuLightText {
        id: selectTextText
        text: privateProps.getSelectText(privateProps.currentChoice)
        font.pixelSize: 14
        color: "white"
        anchors {
            left: verticalSeparator.left
            leftMargin: bg.width / 100 * 3.92
            top: horizontalRightSeparator.bottom
            topMargin: bg.height / 100 * 2.29
        }
    }

    PaginatorOnBackground {
        id: paginator

        property int elementsOnFirstPage: 3
        property int elementsOnOtherPages: 9

        elementsOnPage: 3
        buttonVisible: false
        spacing: 5
        anchors {
            top: selectTextText.bottom
            topMargin: bg.height / 100 * 2.29
            left: verticalSeparator.left
            leftMargin: bg.width / 100 * 3.92
            right: nameBgImage.right
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
                text: delegateRadio.itemObject === undefined ? "" : delegateRadio.itemObject.name // address, type (MediaType), position
                onClicked: page.currentLink = index
                status: page.currentLink === index

                ButtonImageThreeStates {
                    id: deleteButton

                    visible: page.isRemovable
                    defaultImage: "images/common/ico_delete.svg"
                    pressedImage: "images/common/ico_delete_p.svg"
                    defaultImageBg: "images/common/ico_bg.svg"
                    pressedImageBg: "images/common/ico_bg.svg"
                    anchors {
                        verticalCenter: delegateRadio.verticalCenter
                        left: delegateRadio.right
                        leftMargin: bg.width / 100 * 2.51
                    }
                    onClicked: page.actualModel.remove(delegateRadio.itemObject)
                }
            }
        }

        // Redefined to consider that we have 3 elements on first page and 9 on others
        function computePageRange(page, elementsOnPage) {
            if (page === 1)
                return [0, paginator.elementsOnFirstPage]
            return [(page - 2) * paginator.elementsOnOtherPages + paginator.elementsOnFirstPage,
                    (page - 1) * paginator.elementsOnOtherPages + paginator.elementsOnFirstPage]
        }

        // Redefined to consider that we have 3 elements on first page and 9 on others
        function computePagesFromModelSize(modelSize, elementsOnPage) {
            if (modelSize <= paginator.elementsOnFirstPage)
                return 1

            var modelSizeWithoutFirstPage = modelSize - paginator.elementsOnFirstPage
            var ret = modelSizeWithoutFirstPage % paginator.elementsOnOtherPages ?
                        modelSizeWithoutFirstPage / paginator.elementsOnOtherPages + 1 :
                        modelSizeWithoutFirstPage / paginator.elementsOnOtherPages

            return Math.floor(ret + 1)
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
            if (page.currentLink >= 0) {
                // saves selection on current profile
                var current = page.actualModel.getObject(page.currentLink)

                var name = ""
                if (current.name)
                    name = current.name
                var address = ""
                if (current.address)
                    address = current.address
                var btObject = current
                var x = -1
                var y = -1
                var media = privateProps.getTypeText(privateProps.currentChoice)

                myHomeModels.createQuicklink(page.profile.uii, media, name, address, btObject, x, y)
            }
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

    Component {
        id: popupEditLink
        EditNote {
            onOkClicked: linkText.text = text
        }
    }

    Component {
        id: popupEditName
        EditNote {
            onOkClicked: nameText.text = text
        }
    }

    states: [
        State {
            name: "cameras"
            when: privateProps.currentChoice === 0
            PropertyChanges { target: addTextText; opacity: 0 }
            PropertyChanges { target: linkBgImage; opacity: 0 }
            PropertyChanges { target: linkText; opacity: 0 }
            PropertyChanges { target: linkBgImage; opacity: 0 }
            PropertyChanges { target: nameBgImage; opacity: 0 }
            PropertyChanges { target: nameText; opacity: 0 }
            PropertyChanges { target: nameBgImage; opacity: 0 }
            PropertyChanges { target: addButton; opacity: 0 }
            PropertyChanges { target: horizontalRightSeparator; opacity: 0 }
            PropertyChanges { target: selectTextText; opacity: 0 }
            PropertyChanges { target: paginator; elementsOnPage: 9; elementsOnFirstPage: 9 }
            AnchorChanges { target: paginator; anchors.top: horizontalSeparator.bottom }
        },
        State {
            name: "second_page"
            when: paginator.currentPage > 1
            PropertyChanges { target: addTextText; opacity: 0 }
            PropertyChanges { target: linkBgImage; opacity: 0 }
            PropertyChanges { target: linkText; opacity: 0 }
            PropertyChanges { target: linkBgImage; opacity: 0 }
            PropertyChanges { target: nameBgImage; opacity: 0 }
            PropertyChanges { target: nameText; opacity: 0 }
            PropertyChanges { target: nameBgImage; opacity: 0 }
            PropertyChanges { target: addButton; opacity: 0 }
            PropertyChanges { target: horizontalRightSeparator; opacity: 0 }
            PropertyChanges { target: selectTextText; opacity: 0 }
            PropertyChanges { target: paginator; elementsOnPage: 9 }
            AnchorChanges { target: paginator; anchors.top: horizontalSeparator.bottom }
        },
        State {
            name: "normal"
            when: { return true }
            PropertyChanges { target: addTextText; opacity: 1 }
            PropertyChanges { target: linkBgImage; opacity: 1 }
            PropertyChanges { target: linkText; opacity: 1 }
            PropertyChanges { target: linkBgImage; opacity: 1 }
            PropertyChanges { target: nameBgImage; opacity: 1 }
            PropertyChanges { target: nameText; opacity: 1 }
            PropertyChanges { target: nameBgImage; opacity: 1 }
            PropertyChanges { target: addButton; opacity: 1 }
            PropertyChanges { target: horizontalRightSeparator; opacity: 1 }
            PropertyChanges { target: selectTextText; opacity: 1 }
            PropertyChanges { target: paginator; elementsOnPage: 3 }
            AnchorChanges { target: paginator; anchors.top: selectTextText.bottom }
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

        property bool cameraStatus: true
        property bool webPageStatus: false
        property bool webCameraStatus: false
        property bool rssStatus: false
        property bool weatherStatus: false
        property bool scenarioStatus: false

        function getContainerUii(kind, dummy) {
            // camera is not managed by media link model
            if (kind === 1)
                return Container.IdMultimediaWebLink
            if (kind === 2)
                return Container.IdMultimediaWebCam
            if (kind === 3)
                return Container.IdMultimediaRss
            if (kind === 4)
                return Container.IdMultimediaRssMeteo
            if (kind === 5) // scenario
                return -1 // TODO what is this?
            return -1
        }

        function getStatus(kind, dummy) {
            if (kind === 0)
                return privateProps.cameraStatus
            if (kind === 1)
                return privateProps.webPageStatus
            if (kind === 2)
                return privateProps.webCameraStatus
            if (kind === 3)
                return privateProps.rssStatus
            if (kind === 4)
                return privateProps.weatherStatus
            if (kind === 5)
                return privateProps.scenarioStatus
            return false
        }

        function setStatus(kind) {
            if (privateProps.currentChoice === kind)
                return

            privateProps.dummy = !privateProps.dummy // triggers updates
            privateProps.cameraStatus = false
            privateProps.webPageStatus = false
            privateProps.webCameraStatus = false
            privateProps.rssStatus = false
            privateProps.weatherStatus = false
            privateProps.scenarioStatus = false

            privateProps.currentChoice = kind

            if (kind === 0)
                privateProps.cameraStatus = true
            if (kind === 1)
                privateProps.webPageStatus = true
            if (kind === 2)
                privateProps.webCameraStatus = true
            if (kind === 3)
                privateProps.rssStatus = true
            if (kind === 4)
                privateProps.weatherStatus = true
            if (kind === 5)
                privateProps.scenarioStatus = true

            linkText.text = qsTr("Click to enter link...")
            nameText.text = qsTr("Click to enter name...")

            paginator.currentPage = 1
        }

        function getTypeText(kind) {
            if (kind === 0)
                return qsTr("camera")
            if (kind === 1)
                return qsTr("web page")
            if (kind === 2)
                return qsTr("web camera")
            if (kind === 3)
                return qsTr("rss")
            if (kind === 4)
                return qsTr("weather")
            if (kind === 5)
                return qsTr("scenario")
            return " " // a space to avoid zero height text element
        }

        function getSelectText(dummy) {
            if (privateProps.currentChoice === 0)
                return qsTr("Select existing camera:")
            if (privateProps.currentChoice === 1)
                return qsTr("Select existing web page link:")
            if (privateProps.currentChoice === 2)
                return qsTr("Select existing web camera:")
            if (privateProps.currentChoice === 3)
                return qsTr("Select existing rss link:")
            if (privateProps.currentChoice === 4)
                return qsTr("Select existing weather forecast link:")
            if (privateProps.currentChoice === 5)
                return qsTr("Select existing scenario:")
            return " " // a space to avoid zero height text element
        }

        function getAddText(dummy) {
            if (privateProps.currentChoice === 0)
                return qsTr("Add new camera:")
            if (privateProps.currentChoice === 1)
                return qsTr("Add new web page link:")
            if (privateProps.currentChoice === 2)
                return qsTr("Add new web camera:")
            if (privateProps.currentChoice === 3)
                return qsTr("Add new rss link:")
            if (privateProps.currentChoice === 4)
                return qsTr("Add new weather forecast link:")
            if (privateProps.currentChoice === 5)
                return qsTr("Add new scenario:")
            return " " // a space to avoid zero height text element
        }
    }
}
