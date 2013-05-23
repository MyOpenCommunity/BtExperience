import QtQuick 1.1

Item {
    id: paginatorItem

    // expose some ListView properties
    property alias delegate: internalList.delegate
    property alias model: internalList.model
    property alias listHeight: internalList.height
    property alias currentIndex: internalList.currentIndex
    property alias source: background.source

    property int elementsOnPage: 8
    property alias currentPage: paginator.currentPage
    property alias totalPages: paginator.totalPages

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

    function openDelegate(absIndex, openFunc) {
        var indexes = paglistPrivateProps.getIndexesInPaginator(absIndex)
        paginator.goToPage(indexes[0])
        currentIndex = indexes[1]
        var itemObject = model.getObject(currentIndex)
        openFunc(itemObject)
    }

    function refreshSize() {
        paglistPrivateProps.computeDelegateHeight()
    }

    width: internalList.width
    height: internalList.height + paginator.height * paginator.visible

    SvgImage {
        id: background
        source: "../images/common/bg_paginazione.png"
        width: parent.width
        height: parent.height
    }

    ListView {
        id: internalList

        // initially we set values to 1 to be sure to enter inside the if
        // contained in the Component.onCompleted function; this is because
        // a list creates at least one delegate if its width and height are
        // at least 1 both
        property int delegateWidth: 1
        property int delegateHeight: 1

        width: delegateWidth
        // here we calculate the min between elementsOnPage and model.count to
        // know the height of the list; the problems is that model.count is
        // initially zero, so we have to trick with the max function to always
        // have an height of at least 1 (otherwise we miss the if in the
        // Component.onCompleted function)
        height: Math.max(1, delegateHeight * Math.min(elementsOnPage, internalList.model.count))
        interactive: false
        currentIndex: -1
    }

    QtObject {
        // Due to QML scoping rules [1], it's better to use a different name from
        // 'privateProps';  otherwise delegates cannot use functions defined in
        // outer Component's 'privateProps' object. See for example note delegate in Profile.qml.
        //
        // [1] http://doc.qt.nokia.com/4.7-snapshot/qdeclarativescope.html
        id: paglistPrivateProps

        function computeDelegateHeight() {
            if (internalList.children.length === 1 &&
                    internalList.children[0].children.length > 0) {
                // We need to set the width of PaginatorList looking at the delegates;
                // this way, we avoid to use magic numbers (bottom-up approach).
                // See MenuContainer docs to know why we need to set the width
                // Items that may go into a MenuColumn.
                internalList.delegateWidth = internalList.children[0].children[0].width
                internalList.delegateHeight = internalList.children[0].children[0].height
            }
        }

        // function to select an internalList element from an absolute index
        // once the element is selected, it returns the page and the relative index
        // inside the page
        function getIndexesInPaginator(absIndex) {
            // some pages (like AddQuicklink.qml) have a variable number of elements
            // per page, so a simple division doesn't cut it; we must use computePageRange
            for (var p = 1; p <= totalPages; ++p) {
                var r = computePageRange(p, elementsOnPage)
                if (absIndex >= r[0] && absIndex < r[1])
                    return [p, absIndex - r[0]]
            }
            // in case totalPages is zero returns 0
            return [0, 0]
        }
    }

    // Necessary when the notes view is shown and initially empty, otherwise the
    // delegateWidth property is never updated
    Connections {
        target: model
        onCountChanged: paglistPrivateProps.computeDelegateHeight()
    }

    Paginator {
        id: paginator
        totalPages: computePagesFromModelSize(internalList.model.count, elementsOnPage)
        anchors.left: internalList.left
        anchors.top: internalList.bottom
        anchors.right: internalList.right
    }

    Component.onCompleted: paglistPrivateProps.computeDelegateHeight()
}

