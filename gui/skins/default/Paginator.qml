import QtQuick 1.1

Image {
    id: paginator
    width: 210 // 5 ButtonPagination in row
    height: 35
    source: "images/common/bg_paginazione.png"
    visible: pages > 1

    property int pages: 6
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
    }

    Component.onCompleted: {
        if (pages * 42 > paginator.width)
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
        if (privateProps.currentPage + delta >= 1 && privateProps.currentPage + delta <= pages)
            privateProps.currentPage += delta

        if (privateProps.windowLower + delta >= 1)
            privateProps.windowLower += delta

        if (privateProps.windowUpper + delta <= paginator.pages)
            privateProps.windowUpper += delta

        var windowLength = 0
        if (paginator.pages <= 5)
            windowLength = 5
        else if (privateProps.windowLower === 1)
            windowLength = 4
        else if (privateProps.windowUpper === paginator.pages)
            windowLength = 4
        else if (paginator.pages > 5)
            windowLength = 3

        console.log("computed window length: " + windowLength)

        if (privateProps.currentPage === privateProps.windowUpper)
            privateProps.windowLower = privateProps.windowUpper - windowLength + 1
        else
            privateProps.windowUpper = privateProps.windowLower + windowLength - 1

        // clamp window borders
        if (privateProps.windowUpper > paginator.pages)
            privateProps.windowUpper = paginator.pages
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
            model: paginator.pages
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
            when: paginator.pages > 5 && privateProps.windowLower === 1
            PropertyChanges {
                target: rightArrow
                visible: true
            }
        },
        State {
            name: "left_direction"
            when: paginator.pages > 5 && privateProps.windowUpper === paginator.pages
            PropertyChanges {
                target: leftArrow
                visible: true
            }
        },
        State {
            name: "both_directions"
            when: paginator.pages > 5 && privateProps.windowUpper - privateProps.windowLower + 1 === 3
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
