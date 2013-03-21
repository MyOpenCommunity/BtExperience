import QtQuick 1.1

Item {
    id: column
    width: 212
    height: paginator.height * paginator.visible + privateProps.maxPageSize

    property int maxHeight: 300
    signal currentPageChanged

    QtObject {
        id: privateProps
        property int maxPageSize: 100
    }

    Component.onCompleted: {
        showPage(paginator.currentPage)
    }

    SvgImage {
        id: background
        property bool skipMe: true
        source: "../images/common/bg_paginazione.png"
        width: parent.width
        height: parent.height
    }

    function showPage(requestedPage) {
        var pageSize = 0
        var pageNumber = 1
        var maxPageSize = 0
        for (var i = 1; i < column.children.length; i++) {
            var child = column.children[i]
            if (child.skipMe === true)
                continue
            var y = pageSize
            pageSize = pageSize + child.height
            if (pageSize > column.maxHeight) {
                // current item led to overflow, account to next page
                y = 0
                pageSize = child.height
                pageNumber++
                if (maxPageSize > privateProps.maxPageSize)
                    privateProps.maxPageSize = maxPageSize
                maxPageSize = child.height
            }
            else {
                maxPageSize += child.height
            }

            child.visible = pageNumber === requestedPage
            child.y = y
        }
        paginator.totalPages = pageNumber
    }

    Paginator {
        id: paginator
        property bool skipMe: true
        anchors.bottom: parent.bottom
        onCurrentPageChanged: {
            showPage(paginator.currentPage)
            column.currentPageChanged()
        }
    }
}
