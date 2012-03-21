import QtQuick 1.1

Image {
    id: paginator
    // all buttons in the paginator have the same width
    width: privateProps.numSlots * leftArrow.width
    height: leftArrow.height
    source: "images/common/bg_paginazione.png"
    visible: totalPages > 1

    // Number of pages present in the paginator
    property alias totalPages: privateProps.totalPages
    // Currently selected page in the paginator. At the moment this is read only.
    property alias currentPage: privateProps.currentPage
    // The total number of buttons (numbers + arrows) shown in the paginator element.
    property alias numSlots: privateProps.numSlots

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

    // Private details
    //
    QtObject {
        id: privateProps
        // currently selected page
        property int currentPage: 1
        // which slot is currentPage in
        property int offset: 1
        // total number of buttons (arrows + page numbers) visible in the paginator
        property int numSlots: 5
        // total number of pages handled by the paginator
        property int totalPages: 1

        function needScrolling() {
            return totalPages > numSlots
        }

        function needScrollRight() {
            return totalPages - currentPage > numSlots - offset
        }

        function needScrollLeft() {
            return currentPage > offset
        }

        function nextPage() {
            currentPage += 1
            if (offset < numSlots -1)
                offset += 1
        }

        function previousPage() {
            currentPage -= 1
            if (offset > 2)
                offset -= 1
        }

        function goToPage(pageNumber) {
            offset += pageNumber - currentPage
            currentPage = pageNumber
        }

        function isButtonVisible(index) {
            var lowerPage = currentPage - (offset - 1 - (needScrollLeft() ? 1 : 0))
            var upperPage = currentPage + (numSlots - offset - (needScrollRight() ? 1 : 0))
            return (index >= lowerPage) && (index <= upperPage)
        }
    }

    // Needed when the model changes, eg. in antintrusion the alarms may be
    // removed from the model
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
            visible: privateProps.needScrolling() && privateProps.needScrollLeft()

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
            id: repeater
            model: paginator.totalPages
            ButtonPagination {
                pageNumber: index + 1
                onClicked: privateProps.goToPage(pageNumber)
                visible: privateProps.isButtonVisible(pageNumber)
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
            visible: privateProps.needScrolling() && privateProps.needScrollRight()

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
