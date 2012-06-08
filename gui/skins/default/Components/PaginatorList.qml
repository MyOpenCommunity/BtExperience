import QtQuick 1.1

Item {
    id: paginatorItem

    // expose some ListView properties
    property alias footer: internalList.footer
    property alias header: internalList.header
    property alias delegate: internalList.delegate
    property alias model: internalList.model
    property alias listHeight: internalList.height
    property alias listWidth: internalList.width
    property alias buttonVisible: button.visible
    property alias currentIndex: internalList.currentIndex
    property alias source: background.source
    property alias spacing: spacing.height
    property alias leftMargin: leftMargin.width

    property int elementsOnPage: 6
    property alias currentPage: paginator.currentPage
    property alias totalPages: paginator.totalPages

    signal buttonClicked

    // this is needed for updating height when opacity changes
    height: internalList.height + bottomRow.height * bottomRow.opacity

    // Convenience function to compute the visible range of a model
    function computePageRange(page, elementsOnPage) {
        return [(page - 1) * elementsOnPage, page * elementsOnPage]
    }

    // Convenience function to compute the number of pages in the paginator
    // from the model size
    function computePagesFromModelSize(modelSize, elementsOnPage) {
        var ret = modelSize % elementsOnPage ?
                    modelSize / elementsOnPage + 1 :
                    modelSize / elementsOnPage
        return Math.floor(ret)
    }

    SvgImage {
        id: background
        source: "../images/common/bg_paginazione.png"
        width: parent.width
        height: parent.height
    }

    Item {
        id: leftMargin
        anchors.left: parent.left
        width: 0
    }

    ListView {
        id: internalList
        interactive: false
        currentIndex: -1
        // we need to set width and height to at least 1 otherwise the ListView
        // will consider to have zero children and the Component.onCompleted code
        // will not work as expected
        width: 1
        height: 1
        anchors.left: leftMargin.right
    }

    Item {
        id: spacing
        anchors.top: internalList.bottom
        height: 0
    }

    Item {
        id: bottomRow
        anchors.left: internalList.left
        anchors.right: internalList.right
        anchors.top: spacing.bottom
        opacity: ((paginator.visible === true) || (button.visible === true)) ? 1 : 0
        height: Math.max(paginator.height, button.height)

        Paginator {
            id: paginator
            totalPages: computePagesFromModelSize(internalList.model.count, elementsOnPage)
            anchors.left: parent.left
            anchors.leftMargin: parent.width / 100 * 1
        }

        ButtonThreeStates {
            id: button
            visible: false
            anchors.right: parent.right
            anchors.rightMargin: parent.width / 100 * 1
            defaultImage: "../images/common/button_delete_all.svg"
            pressedImage: "../images/common/button_delete_all_press.svg"
            shadowImage: "../images/common/shadow_button_delete_all.svg"
            text: qsTr("remove all")
            font.capitalization: Font.AllUppercase
            font.pixelSize: 12
            onClicked: paginatorItem.buttonClicked()
            status: 0
        }
    }

    Component.onCompleted: {
        if (internalList.children.length === 1 &&
                internalList.children[0].children.length > 0) {
            // We need to set the width of PaginatorList looking at the delegates;
            // this way, we avoid to use magic numbers (bottom-up approach).
            // See MenuContainer docs to know why we need to set the width
            // Items that may go into a MenuColumn.
            var delegateWidth = internalList.children[0].children[0].width
            width = delegateWidth
            internalList.width = delegateWidth
            var delegateHeight = internalList.children[0].children[0].height
            internalList.height = delegateHeight * Math.min(elementsOnPage, internalList.model.count)
            height = internalList.height + bottomRow.height * bottomRow.opacity
        }
    }
}

