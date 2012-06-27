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

    QtObject {
        id: privateProps

        function computeDelegateHeight() {
            if (internalList.children.length === 1 &&
                    internalList.children[0].children.length > 0) {
                // See PaginatorList for comments
                internalList.delegateWidth = internalList.children[0].children[0].width
                internalList.delegateHeight = internalList.children[0].children[0].height
            }
        }
    }

    // Necessary when the alarm log is shown and initially empty, otherwise the
    // delegateWidth property is never updated
    Connections {
        target: model
        onCountChanged: privateProps.computeDelegateHeight()
    }

    ListView {
        property int delegateWidth: 1
        property int delegateHeight: 1

        id: internalList
        interactive: false
        currentIndex: -1
        // see comments in PaginatorList
        width: delegateWidth
        height: delegateHeight * elementsOnPage

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
            defaultImage: "../../images/common/button_delete_all.svg"
            pressedImage: "../../images/common/button_delete_all_press.svg"
            shadowImage: "../../images/common/shadow_button_delete_all.svg"
            text: qsTr("remove all")
            font.capitalization: Font.AllUppercase
            font.pixelSize: 12
            onClicked: paginatorItem.buttonClicked()
            status: 0
        }
    }

    Component.onCompleted: privateProps.computeDelegateHeight()
}

