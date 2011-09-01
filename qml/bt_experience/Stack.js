// This declaration makes the javascript code share the execution context between
// different qml files.

.pragma library

var stack = []

var container = null

var current_index = -1

var changing_page = false


// Create a QML object from a given filename and push it on the stack
function openPage(filename) {
    if (changing_page == true)
        return

    if (stack.length > 0)
        changing_page = true

    var page_component = Qt.createComponent(filename)
    var page = page_component.createObject(container)
    pushPage(page)
    return page
}

function pushPage(page) {
    if (stack.length > 0) {
        page.state = 'offscreen_right'
        page.state = ''
        page.z = 1
    }

    stack.push(page)
    current_index = stack.length - 1;
}

function showPreviousPage(index) {
    if (changing_page == true)
        return

    changing_page = true

    stack[index].visible = true
    stack[index].z = 1
    stack[index].state = 'offscreen_left'
    stack[index].state = ''
    current_index = index
}

function popPage() {
    if (stack.length > 1)
        showPreviousPage(stack.length - 2)
}

function backToHome() {
    showPreviousPage(0)
}

function changePageDone() {
    for (var i = 0; i < stack.length; i++) {
        if (i != current_index)
            stack[i].visible = false

        if (i <= current_index)
            stack[i].z = 0
        else if (i > current_index)
            stack[i].destroy()
    }
    stack.length = current_index + 1
    changing_page = false
}

