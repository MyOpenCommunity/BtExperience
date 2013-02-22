import QtQuick 1.1

Item {
    id: paginator
    // all buttons in the paginator have the same width
    width: privateProps.numSlots * leftArrow.width
    height: leftArrow.height
    visible: totalPages > 1

    // Number of pages present in the paginator
    property alias totalPages: privateProps.totalPages
    // Currently selected page in the paginator. At the moment this is read only.
    property alias currentPage: privateProps.currentPage
    // The total number of buttons (numbers + arrows) shown in the paginator element.
    property alias numSlots: privateProps.numSlots

    // useful in dynamic navigation
    function goToPage(pageNumber) {
        privateProps.offset += pageNumber - privateProps.currentPage
        privateProps.currentPage = pageNumber
        privateProps.updateWindow()
    }

    // Private details
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

        function isButtonVisible(index) {
            var lowerPage = currentPage - (offset - 1 - (needScrollLeft() ? 1 : 0))
            var upperPage = currentPage + (numSlots - offset - (needScrollRight() ? 1 : 0))
            return (index >= lowerPage) && (index <= upperPage)
        }

        function updateWindow() {
            // if totalPages is less than currentPage sets currentPage to totalPages
            if (privateProps.totalPages < privateProps.currentPage && privateProps.totalPages > 0)
                privateProps.currentPage = privateProps.totalPages

            // now we need to adjust the offset
            if (privateProps.totalPages <= privateProps.numSlots) {
                privateProps.offset = privateProps.currentPage
                return
            }

            // computes window center
            var center = Math.ceil(privateProps.numSlots / 2)

            // checks if left window side is valid, if not adjusts offset
            if (privateProps.currentPage < center) {
                // moves window to the right
                privateProps.offset = privateProps.currentPage
                return
            }

            // checks if right window side is valid, if not adjusts offset
            if (privateProps.currentPage + privateProps.numSlots - center > privateProps.totalPages) {
                privateProps.offset = privateProps.currentPage + privateProps.numSlots - privateProps.totalPages
                return
            }

            // checks that offset is not outside the range of valid slots
            if (privateProps.offset >= privateProps.numSlots) {
                privateProps.offset = privateProps.numSlots - 1
                return
            }
        }

        // Needed when the model changes, eg. in antintrusion the alarms may be
        // removed from the model
        onTotalPagesChanged: privateProps.updateWindow()
    }

    Row {
        id: buttonRow
        anchors.fill: parent

        ButtonThreeStates {
            id: leftArrow
            visible: privateProps.needScrolling() && privateProps.needScrollLeft()
            defaultImage: "../images/common/button_pager.svg"
            pressedImage: "../images/common/button_pager_press.svg"
            selectedImage: "../images/common/button_pager_select.svg"
            shadowImage: "../images/common/shadow_button_pager.svg"
            onTouched: privateProps.previousPage()

            SvgImage {
                id: image1
                source: "../images/common/icon_pager_arrow.svg"
                anchors.centerIn: parent
                rotation: 180

                states: [
                    State {
                        name: "pressedOrSelected"
                        when: (leftArrow.state === "pressed") || (leftArrow.state === "selected")
                        PropertyChanges { target: image1; source: "../images/common/icon_pager_arrow_select.svg" }
                    }
                ]
            }
        }

        Repeater {
            id: repeater
            model: paginator.totalPages

            ButtonThreeStates {
                property int pageNumber: index + 1
                visible: privateProps.isButtonVisible(pageNumber)
                text: pageNumber
                defaultImage: "../images/common/button_pager.svg"
                pressedImage: "../images/common/button_pager_press.svg"
                selectedImage: "../images/common/button_pager_select.svg"
                shadowImage: "../images/common/shadow_button_pager.svg"
                onTouched: goToPage(pageNumber)
                status: privateProps.currentPage === pageNumber ? 1 : 0
            }
        }

        ButtonThreeStates {
            id: rightArrow
            visible: privateProps.needScrolling() && privateProps.needScrollRight()
            defaultImage: "../images/common/button_pager.svg"
            pressedImage: "../images/common/button_pager_press.svg"
            selectedImage: "../images/common/button_pager_select.svg"
            shadowImage: "../images/common/shadow_button_pager.svg"
            onTouched: privateProps.nextPage()

            SvgImage {
                id: image2
                source: "../images/common/icon_pager_arrow.svg"
                anchors.centerIn: parent

                states: [
                    State {
                        name: "pressedOrSelected"
                        when: (rightArrow.state === "pressed") || (rightArrow.state === "selected")
                        PropertyChanges { target: image2; source: "../images/common/icon_pager_arrow_select.svg" }
                    }
                ]
            }
        }
    }
}
