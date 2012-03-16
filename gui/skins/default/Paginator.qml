import QtQuick 1.1

Image {
    id: paginator
    width: 210 // 5 ButtonPagination in row
    height: 35
    source: "images/common/bg_paginazione.png"
    visible: totalPages > 1

    property int totalPages: 6
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

        // lower page visible (inclusive)
        property int windowLower: 1
        // upper page visible (inclusive)
        property int windowUpper: 5

        function needPagination() {
            return paginator.totalPages > 5
        }
    }

    onTotalPagesChanged: {
        if (privateProps.currentPage > paginator.totalPages && paginator.totalPages > 0)
            privateProps.currentPage = paginator.totalPages
    }

    Component.onCompleted: {
        if (totalPages * 42 > paginator.width)
            privateProps.windowUpper = 4
        showButtons()
    }

    function showButtons() {
        // don't consider right/left buttons and the repeater itself
        for (var i = 1; i < buttonRow.children.length - 2; i++) {
            var child = buttonRow.children[i]
            if (i >= privateProps.windowLower && i <= privateProps.windowUpper)
                child.visible = true
            else
                child.visible = false
        }
    }

    // Behaviour on arrow click: move current page by 1 and the window as well.
    // Window length is adjusted based depending on the position of the
    // current page and the window itself
    function choosePage(delta) {
        if (privateProps.currentPage + delta >= 1 && privateProps.currentPage + delta <= totalPages)
            privateProps.currentPage += delta

        if (privateProps.windowLower + delta >= 1)
            privateProps.windowLower += delta

        if (privateProps.windowUpper + delta <= paginator.totalPages)
            privateProps.windowUpper += delta

        var windowLength = 3 // need both buttons
        if (!privateProps.needPagination())
            windowLength = 5
        else {
            if (privateProps.windowLower === 1)
                windowLength = 4
            else if (privateProps.windowUpper === paginator.totalPages)
                windowLength = 4
        }

        console.log("computed window length: " + windowLength)

        if (privateProps.currentPage === privateProps.windowUpper)
            privateProps.windowLower = privateProps.windowUpper - windowLength + 1
        else
            privateProps.windowUpper = privateProps.windowLower + windowLength - 1

        // clamp window borders
        if (privateProps.windowUpper > paginator.totalPages)
            privateProps.windowUpper = paginator.totalPages
        if (privateProps.windowLower < 1)
            privateProps.windowLower = 1

        console.log("lower: " + privateProps.windowLower + ", upper: " + privateProps.windowUpper)

        if (privateProps.currentPage > privateProps.windowUpper || privateProps.currentPage < privateProps.windowLower)
            console.log(" ***********        currentPage is out of bounds!   ************")

        showButtons()
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
            visible: false

            Image {
                id: image1
                x: 10
                y: 4
                source: "images/common/freccia_sx.png"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    choosePage(-1)
                }
            }
        }

        Repeater {
            model: paginator.totalPages
            ButtonPagination {
                pageNumber: index + 1
                onClicked: privateProps.currentPage = pageNumber
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
            visible: false

            Image {
                id: image2
                x: 10
                y: 3
                source: "images/common/freccia_dx.png"
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    choosePage(1)
                }
            }
        }
    }

    states: [
        State {
            name: "right_direction"
            when: privateProps.needPagination() && privateProps.windowLower === 1
            PropertyChanges {
                target: rightArrow
                visible: true
            }
        },
        State {
            name: "left_direction"
            when: privateProps.needPagination() && privateProps.windowUpper === paginator.totalPages
            PropertyChanges {
                target: leftArrow
                visible: true
            }
        },
        State {
            name: "both_directions"
            when: privateProps.needPagination() && privateProps.windowUpper - privateProps.windowLower + 1 === 3
            PropertyChanges {
                target: rightArrow
                visible: true
            }
            PropertyChanges {
                target: leftArrow
                visible: true
            }
        }
    ]
}
