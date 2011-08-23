// This declaration makes the javascript code share the execution context between
// different qml files.

.pragma library

var stack = []

var container = null

var current_index = -1


// Create a QML object from a given filename and push it on the stack
function openPage(filename) {
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

function pushPageDone() {
    for (var i = 1; i < stack.length; i++)
        stack[i].z = 0
}


function popPage() {
    if (stack.length > 1) {
        var prev_index = stack.length - 2
        stack[prev_index].state = 'offscreen_left'
        stack[prev_index].state = ''
        stack[prev_index].z = 1
        current_index = prev_index
    }
}

function backToHome() {
    stack[0].state = 'offscreen_left'
    stack[0].state = ''
    stack[0].z = 1
    current_index = 0
}

function backToHomeDone() {
    for (var i = current_index + 1; i < stack.length; i++) {
        stack[i].visible = false
        stack[i].destroy()
    }

    stack.length = current_index + 1
    stack[current_index].z = 0
}


