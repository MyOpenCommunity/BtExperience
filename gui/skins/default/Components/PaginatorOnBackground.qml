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
import Components 1.0

Item {
    id: paginatorItem

    // expose some ListView properties
    property alias delegate: internalList.delegate
    property alias model: internalList.model
    property alias spacing: spacing.height
    property alias bottomRowAnchors: bottomRow.anchors
    property alias buttonComponent: button.sourceComponent
    property alias itemSpacing: internalList.spacing

    property int elementsOnPage: 8
    property alias currentPage: paginator.currentPage
    property alias totalPages: paginator.totalPages

    // Convenience function to compute the visible range of a model
    function computePageRange(page, elementsOnPage) {
        return [(page - 1) * elementsOnPage, page * elementsOnPage]
    }

    function goToPage(pageNumber) {
        paginator.goToPage(pageNumber)
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
        internalList.currentIndex = indexes[1]
        var itemObject = model.getObject(internalList.currentIndex)
        openFunc(itemObject)
    }

    QtObject {
        id: paglistPrivateProps

        function computeDelegateHeight() {
            if (internalList.children.length === 1 &&
                    internalList.children[0].children.length > 0) {
                // See PaginatorList for comments
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

    // Necessary when the alarm log is shown and initially empty, otherwise the
    // delegateWidth property is never updated
    Connections {
        target: model
        onCountChanged: paglistPrivateProps.computeDelegateHeight()
    }

    ListView {
        property int delegateWidth: 1
        property int delegateHeight: 1

        id: internalList
        interactive: false
        currentIndex: -1
        // see comments in PaginatorList
        width: delegateWidth
        height: delegateHeight * elementsOnPage + itemSpacing * (elementsOnPage - 1)

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
        opacity: ((paginator.visible === true) || (button.sourceComponent !== undefined)) ? 1 : 0
        height: Math.max(paginator.height, button.height)

        Paginator {
            id: paginator
            totalPages: computePagesFromModelSize(internalList.model.count, elementsOnPage)
            anchors.left: parent.left
        }

        Loader {
            id: button
            anchors.right: parent.right
        }
    }

    Component.onCompleted: paglistPrivateProps.computeDelegateHeight()
}

