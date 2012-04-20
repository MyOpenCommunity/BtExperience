import QtQuick 1.1

Item {
    id: column
    width: 212
    height: paginator.height * paginator.visible + privateProps.currentPageSize

    property int maxHeight: 300
    signal currentPageChanged

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
        for (var i = 1; i < column.children.length; i++)
        {
            var child = column.children[i]
            var y = pageSize
            pageSize = pageSize + child.height
            if (pageSize > column.maxHeight)
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
        onCurrentPageChanged: {
            showPage(paginator.currentPage)
            column.currentPageChanged()
        }
    }
}
