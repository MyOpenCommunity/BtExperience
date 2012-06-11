import QtQuick 1.1
import Components 1.0

Item {
    id: paginatorItem

    // expose some ListView properties
    property alias delegate: internalList.delegate
    property alias model: internalList.model
    property alias buttonVisible: button.visible
    property alias currentIndex: internalList.currentIndex
    property alias spacing: spacing.height

    property int elementsOnPage: 6
    property alias currentPage: paginator.currentPage
    property alias totalPages: paginator.totalPages

    signal buttonClicked

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

    ListView {
        id: internalList
        interactive: false
        currentIndex: -1
        // we need to set width and height to at least 1 otherwise the ListView
        // will consider to have zero children and the Component.onCompleted code
        // will not work as expected
        width: 1
        height: 1
        anchors.left: parent.left
    }

    Item {
        id: spacing
        anchors.top: internalList.bottom
        height: 0
    }

    Item {
        id: bottomRow
        anchors {
            left: internalList.left
            right: internalList.right
            bottom: parent.bottom
            bottomMargin: parent.height / 100 * 1
        }
        opacity: ((paginator.visible === true) || (button.visible === true)) ? 1 : 0
        height: Math.max(paginator.height, button.height)

        Paginator {
            id: paginator
            totalPages: computePagesFromModelSize(internalList.model.count, elementsOnPage)
            anchors.left: parent.left
        }

        ButtonThreeStates {
            id: button
            visible: false
            anchors.right: parent.right
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
            internalList.width = delegateWidth
            var delegateHeight = internalList.children[0].children[0].height
            internalList.height = delegateHeight * Math.min(elementsOnPage, internalList.model.count)
        }
    }
}

