import QtQuick 1.1

ListView {
    id: element
    height: 50 * count + paginator.height
    currentIndex: -1
    interactive: false

    property int maxHeight: 300
    property int elementsOnPage: maxHeight / 50
    // TODO: is it necessary to expose it?
    property alias currentPage: paginator.currentPage


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

    Paginator {
        id: paginator
        y: 50 * count
        width: parent.width
        totalPages: computePagesFromModelSize(model.size, elementsOnPage)
    }
}

