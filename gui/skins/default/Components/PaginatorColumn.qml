/*
 * Copyright © 2011-2013 BTicino S.p.A.
 *
 * This file is part of BtExperience.
 *
 * BtExperience is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BtExperience is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BtExperience. If not, see <http://www.gnu.org/licenses/>.
 */

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
