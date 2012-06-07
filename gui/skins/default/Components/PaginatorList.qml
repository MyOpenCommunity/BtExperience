import QtQuick 1.1

Item {
    id: paginatorItem
    height: internalList.height

    // expose some ListView properties
    property alias footer: internalList.footer
    property alias header: internalList.header
    property alias delegate: internalList.delegate
    property alias model: internalList.model
    property alias listHeight: internalList.height
    property alias listWidth: internalList.width
    property alias buttonVisible: button.visible
    property alias currentIndex: internalList.currentIndex

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
    }

    Item {
        id: bottomRow
        height: button.height / 100 * 150
        width: parent.width
        anchors.bottom: internalList.bottom

        Paginator {
            id: paginator
            totalPages: computePagesFromModelSize(internalList.model.count, elementsOnPage)
            anchors.left: parent.left
            anchors.leftMargin: parent.width / 100 * 2
            anchors.bottom: parent.bottom
            anchors.bottomMargin: parent.height / 100 * 15
        }

        ButtonThreeStates {
            id: button
            visible: false
            anchors.right: parent.right
            anchors.rightMargin: parent.width / 100 * 2
            anchors.bottom: parent.bottom
            anchors.bottomMargin: parent.height / 100 * 15
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
}

