import QtQuick 1.1
import BtObjects 1.0
import BtExperience 1.0
import Components 1.0
import Components.Text 1.0
import Components.Settings 1.0

import "js/Stack.js" as Stack

Page {
    id: page

    property variant profile: undefined
    property int currentLink: -1
    property bool homeCustomization: false
    property bool onlyQuicklinks: false

    // the following properties are used by delegates
    property variant actualModel: privateProps.getActualModel(privateProps.currentIndex, page.onlyQuicklinks)
    property bool isRemovable: privateProps.isRemovable(privateProps.currentIndex, page.onlyQuicklinks)

    text: privateProps.getColumnText(page.profile, page.homeCustomization, page.onlyQuicklinks)
    source: privateProps.getBackgroundImage(page.profile)

    onCurrentLinkChanged: {
        if (page.currentLink < 0) {
            linkText.realText = ""
            nameText.realText = ""
        }
        else {
            var current = page.actualModel.getObject(page.currentLink)

            if (current.address)
                linkText.realText = current.address

            if (current.name)
                nameText.realText = current.name
        }
    }

    ListModel { id: choices }

    Component.onCompleted: {
        if (!onlyQuicklinks)
            choices.append({ type: qsTr("camera"), selectText: qsTr("Select existing camera:"),
                               addText: qsTr("Add new camera:"), containerUii: -1})
        choices.append({ type: qsTr("web page"), selectText: qsTr("Select existing web page link:"),
                           addText: qsTr("Add new web page link:"), containerUii: Container.IdMultimediaWebLink})
        choices.append({ type: qsTr("web camera"), selectText: qsTr("Select existing web camera:"),
                           addText: qsTr("Add new web camera:"), containerUii: Container.IdMultimediaWebCam})
        choices.append({ type: qsTr("rss"), selectText: qsTr("Select existing rss link:"),
                           addText: qsTr("Add new rss link:"), containerUii: Container.IdMultimediaRss})
        choices.append({ type: qsTr("weather"), selectText: qsTr("Select existing weather forecast link:"),
                           addText: qsTr("Add new weather forecast link:"), containerUii: Container.IdMultimediaRssMeteo})
        if (!onlyQuicklinks)
            choices.append({ type: qsTr("scenario"), selectText: qsTr("Select existing scenario:"),
                               addText: qsTr("Add new scenario:"), containerUii: -1})
        choices.append({ type: qsTr("web radio"), selectText: qsTr("Select existing web radio:"),
                           addText: qsTr("Add new web radio:"), containerUii: Container.IdMultimediaWebRadio})

        repeater.model = choices.count
        privateProps.currentIndex = 0 // forces update of paginator model
    }

    SystemsModel { id: linksModel; systemId: choices.get(privateProps.currentIndex).containerUii; source: myHomeModels.mediaContainers }

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

    ObjectModel {
        id: scenariosModel
        filters: [
            {objectId: ObjectInterface.IdSimpleScenario },
            {objectId: ObjectInterface.IdScenarioModule },
            {objectId: ObjectInterface.IdScenarioPlus },
            {objectId: ObjectInterface.IdAdvancedScenario },
            {objectId: ObjectInterface.IdScheduledScenario}
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
            id: repeater
            model: 0
            delegate: ControlRadioHorizontal {
                width: bg.width / 100 * 23.55
                text: choices.get(index).type
                onClicked: {
                    if (privateProps.currentIndex === index)
                        return
                    privateProps.currentIndex = index
                    page.currentLink = -1
                    linkText.realText = ""
                    nameText.realText = ""
                    paginator.currentPage = 1
                }
                status:  privateProps.currentIndex === index
            }
        }
    }

    // upper-right panel
    UbuntuLightText {
        id: addTextText
        text: choices.get(privateProps.currentIndex).addText
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
        id: nameBgImage
        source: "images/common/bg_text-input.svg"
        anchors {
            left: verticalSeparator.left
            leftMargin: bg.width / 100 * 3.92
            top: addTextText.bottom
            topMargin: bg.height / 100 * 2.29
        }

        UbuntuLightText {
            id: nameText

            property string realText: ""
            onRealTextChanged: console.log("nameText.realText: " + realText)

            text: realText || privateProps.emptyNameString
            font.pixelSize: 14
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
            onClicked: installPopup(popupEditLink)
        }
    }

    SvgImage {
        id: linkBgImage
        source: "images/common/bg_text-input.svg"
        anchors {
            left: verticalSeparator.left
            leftMargin: bg.width / 100 * 3.92
            top: nameBgImage.bottom
            topMargin: bg.height / 100 * 2.29
        }

        UbuntuLightText {
            id: linkText

            property string realText: ""
            onRealTextChanged: console.log("linkText.realText: " + realText)

            text: realText || privateProps.emptyAddressString
            font.pixelSize: 14
            color: "#5A5A5A"
            elide: Text.ElideMiddle
            anchors {
                left: linkBgImage.left
                leftMargin: bg.width / 100 * 1.5
                right: linkBgImage.right
                rightMargin: bg.width / 100 * 1.5
                verticalCenter: linkBgImage.verticalCenter
            }
        }

        BeepingMouseArea {
            anchors.fill: linkBgImage
            onClicked: installPopup(popupEditLink)
        }
    }

    ButtonThreeStates {
        id: addButton

        defaultImage: "images/common/btn_99x35.svg"
        pressedImage: "images/common/btn_99x35_P.svg"
        shadowImage: "images/common/btn_shadow_99x35.svg"
        text: qsTr("ADD")
        font.pixelSize: 14

        anchors {
            left: verticalSeparator.left
            leftMargin: bg.width / 100 * 3.92
            top: linkBgImage.bottom
            topMargin: bg.height / 100 * 2.29
        }
        onClicked: {
            if (nameText.realText === "" || linkText.realText === "")
                return
            myHomeModels.createQuicklink(-1, choices.get(privateProps.currentIndex).type, nameText.realText, linkText.realText)
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
        text: choices.get(privateProps.currentIndex).selectText
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
                text: delegateRadio.itemObject === undefined ? "" : delegateRadio.itemObject.name
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
                    onClicked: page.installPopup(confirmDeleteDialog, {"itemObject": delegateRadio.itemObject})
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

    Component {
        id: confirmDeleteDialog

        TextDialog {
            property variant itemObject

            function okClicked() {
                page.actualModel.remove(itemObject)
            }

            title: qsTr("Confirm deletion")
            text: qsTr("Do you want to remove the selected quicklink?\nName: %1\nAddress: %2").arg(itemObject.name).arg(itemObject.address)
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
        visible: page.homeCustomization || page.profile !== undefined
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
        visible: page.homeCustomization || page.profile !== undefined
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
        visible: page.homeCustomization || page.profile !== undefined
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
                var media = choices.get(privateProps.currentIndex).type
                var uii = page.homeCustomization ? myHomeModels.homepageLinks.uii : page.profile.uii

                myHomeModels.createQuicklink(uii, media, name, address, btObject, x, y, page.homeCustomization)
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
        visible: page.homeCustomization || page.profile !== undefined
        onClicked: Stack.popPage()
    }

    Component {
        id: popupEditLink
        FavoriteEditPopup {
            title: qsTr("Edit quicklink properties")
            topInputLabel: qsTr("Title:")
            topInputText: nameText.realText
            bottomInputLabel: qsTr("Address:")
            bottomInputText: linkText.realText

            function okClicked() {
                nameText.realText = topInputText
                linkText.realText = bottomInputText
            }
        }
    }

    states: [
        State {
            name: "init"
            when: privateProps.currentIndex === -1
            PropertyChanges { target: addTextText; opacity: 0 }
            PropertyChanges { target: linkBgImage; opacity: 0 }
            PropertyChanges { target: nameBgImage; opacity: 0 }
            PropertyChanges { target: addButton; opacity: 0 }
            PropertyChanges { target: horizontalRightSeparator; opacity: 0 }
            PropertyChanges { target: selectTextText; opacity: 0 }
        },
        State {
            name: "cameras"
            when: privateProps.currentIndex === 0 && !page.onlyQuicklinks
            PropertyChanges { target: addTextText; opacity: 0 }
            PropertyChanges { target: linkBgImage; opacity: 0 }
            PropertyChanges { target: nameBgImage; opacity: 0 }
            PropertyChanges { target: addButton; opacity: 0 }
            PropertyChanges { target: horizontalRightSeparator; opacity: 0 }
            PropertyChanges { target: selectTextText; opacity: 0 }
            PropertyChanges { target: paginator; elementsOnPage: 9; elementsOnFirstPage: 9 }
            AnchorChanges { target: paginator; anchors.top: horizontalSeparator.bottom }
        },
        State {
            name: "scenarios"
            when: privateProps.currentIndex === 5 && !page.onlyQuicklinks
            PropertyChanges { target: addTextText; opacity: 0 }
            PropertyChanges { target: linkBgImage; opacity: 0 }
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

        property int currentIndex: -1

        // Consider these properties constant
        property string emptyAddressString: qsTr("Click to enter link...")
        property string emptyNameString: qsTr("Click to enter name...")

        function getColumnText(profile, homeCustomization, onlyQuicklinks) {
            if (homeCustomization)
                return qsTr("Home")
            if (onlyQuicklinks)
                return qsTr("Multimedia")
            if (profile === undefined)
                return qsTr("Profiles")
            return profile.description
        }

        function getBackgroundImage(profile, homeCustomization, onlyQuicklinks) {
            if (profile !== undefined && profile.image !== "")
                return profile.image
            return homeProperties.homeBgImage
        }

        function getActualModel(index, onlyQuicklinks) {
            if (onlyQuicklinks)
                return quicklinksModel
            if (index === 0)
                return camerasModel
            if (index === 5)
                return scenariosModel
            return quicklinksModel
        }

        function isRemovable(index, onlyQuicklinks) {
            if (onlyQuicklinks)
                return true
            if (index === 0)
                return false
            if (index === 5)
                return false
            return true
        }
    }
}
