import QtQuick 1.1

Image {
    id: paginator
//    width: 210 // 5 ButtonPagination in row
    height: 35
    source: "images/common/bg_paginazione.png"
    visible: totalPages > 1

    property alias totalPages: privateProps.totalPages
    property alias currentPage: privateProps.currentPage

    function computePageRange(page, elementsOnPage) {
        return [(page - 1) * elementsOnPage, page * elementsOnPage]
    }

    function computePagesFromModelSize(modelSize, elementsOnPage) {
        var ret = modelSize % elementsOnPage ?
               modelSize / elementsOnPage + 1 :
               modelSize / elementsOnPage
        return Math.floor(ret)
    }

    QtObject {
        id: privateProps
        property int currentPage: 1
        property int offset: 1
        property int numSlots: 5
        property int totalPages: 6

        function needPagination() {
            return totalPages > numSlots
        }

        function needRightArrow() {
            return totalPages - currentPage > numSlots - offset
        }

        function needLeftArrow() {
            return currentPage > offset
        }

        function nextPage() {
            currentPage += 1
            if (offset < numSlots -1)
                offset += 1

            showButtons()
        }

        function previousPage() {
            currentPage -= 1
            if (offset > 2)
                offset -= 1

            showButtons()
        }

        function goToPage(pageNumber) {
            offset += pageNumber - currentPage
            currentPage = pageNumber
        }

        function showButtons() {
            var lowerPage = currentPage - (offset - 1 - (needLeftArrow() ? 1 : 0))
            var upperPage = currentPage + (numSlots - offset - (needRightArrow() ? 1 : 0))

            for (var i = 1; i < buttonRow.children.length - 2; i++) {
                var child = buttonRow.children[i]
                child.visible = (i >= lowerPage && i <= upperPage)
            }
        }
    }
    Component.onCompleted: {
        privateProps.showButtons()
    }

    onTotalPagesChanged: {
        if (privateProps.currentPage > paginator.totalPages && paginator.totalPages > 0)
            privateProps.currentPage = paginator.totalPages
    }


    Row {
        id: buttonRow
        anchors.fill: parent

        Image {
            // TODO: copy-pasted from ButtonPagination, make it better
            id: leftArrow
            width: 42
            height: 35
            source: "images/common/btn_NumeroPagina.png"
            visible: privateProps.needPagination() && privateProps.needLeftArrow()

            Image {
                id: image1
                x: 10
                y: 4
                source: "images/common/freccia_sx.png"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: privateProps.previousPage()

            }
        }

        Repeater {
            model: paginator.totalPages
            ButtonPagination {
                pageNumber: index + 1
                onClicked: privateProps.goToPage(pageNumber)
                states: [
                    State {
                        name: "extselected"
                        extend: "selected"
                        when: privateProps.currentPage === pageNumber
                    }
                ]
            }

        }

        Image {
            // TODO: copy-pasted from ButtonPagination, make it better
            id: rightArrow
            width: 42
            height: 35
            source: "images/common/btn_NumeroPagina.png"
            visible: privateProps.needPagination() && privateProps.needRightArrow()

            Image {
                id: image2
                x: 10
                y: 3
                source: "images/common/freccia_dx.png"
            }
            MouseArea {
                anchors.fill: parent
                onClicked: privateProps.nextPage()
            }
        }
    }
}
