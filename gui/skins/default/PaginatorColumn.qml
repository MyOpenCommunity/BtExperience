import QtQuick 1.1

Item {
    id: element
    width: 212
    height: paginator.height + privateProps.currentPageSize

    property int maxHeight: 300

    QtObject {
        id: privateProps
        property int currentPageSize: 100
    }

    Component.onCompleted: {
        showPage(paginator.currentPage)
    }

    function showPage(requestedPage) {
        var pageSize = 0
        var pageNumber = 1
        for (var i = 1; i < element.children.length; i++)
        {
            var child = element.children[i]
            var y = pageSize
            pageSize = pageSize + child.height
            if (pageSize > element.maxHeight)
            {
                // current item led to overflow, account to next page
                y = 0
                pageSize = child.height
                pageNumber++
            }
            if (pageNumber === requestedPage)
                privateProps.currentPageSize = pageSize

            child.visible = pageNumber === requestedPage
            child.y = y
        }
        paginator.totalPages = pageNumber
    }

    Paginator {
        id: paginator
        y: privateProps.currentPageSize
        onCurrentPageChanged: showPage(paginator.currentPage)
    }
}
