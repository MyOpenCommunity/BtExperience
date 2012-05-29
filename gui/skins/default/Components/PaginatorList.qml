import QtQuick 1.1

Item {
    id: paginatorItem
    height: internalList.height + bottomRow.height * paginator.visible

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

    Row {
        id: bottomRow
        height: paginator.height
        width: parent.width
        anchors.bottom: parent.bottom

        Paginator {
            id: paginator
            totalPages: computePagesFromModelSize(internalList.model.count, elementsOnPage)
        }

        Image {
            id: button
            source: "../images/common/btn_OKAnnulla.png"
            height: paginator.height
            visible: false
            width: parent.width - paginator.width * paginator.visible

            Text {
                text: qsTr("remove all")
                font.capitalization: Font.AllUppercase
                font.pixelSize: 12
                anchors.centerIn: parent
            }

            MouseArea {
                anchors.fill: parent
                onClicked: paginatorItem.buttonClicked()
            }
        }
    }
}

