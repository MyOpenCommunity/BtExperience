// This declaration makes the javascript code share the execution context between
// different qml files.

.pragma library
Qt.include("logging.js")

var stack = []

var container = null

var current_index = -1

var changing_page = false


// Create a QML object from a given filename and push it on the stack
function openPage(filename, properties) {
    // automatically set _pageName from component filename
    var page_name = filename.split('.')[0]
    if (properties === undefined)
        properties = {}
    if (properties['_pageName'] === undefined)
        properties['_pageName'] = page_name

    return _openPage(filename, properties)
}

function _deletePages(list) {
    for (var i = 0; i < list.length; ++i)
        list[i].destroy()
}

// Create a QML object from a given filename and push it on the stack
function _openPage(filename, properties) {
    if (changing_page == true)
        return

    if (stack.length > 0)
        changing_page = true

    var page = undefined
    var deletingPages = []
    while (filename !== "")
    {
        // now, Stack.js is in a js subdir so we have to trick the filename
        var page_component = Qt.createComponent("../" + filename)
        // The component status (like the Component.Ready that has 1 as value) is not currently
        // available on js files that uses .pragma library declaration.
        // This should be fixed in the future:
        // http://lists.qt.nokia.com/pipermail/qt-qml/2010-November/001713.html
        if (page_component.status === 1) {
            page = page_component.createObject(container, typeof properties !== 'undefined' ? properties : {})
            if (page === null) {
                logError('Error on creating the object for the page: ' + filename)
                logError('Properties:')
                for(var k in properties)
                    logError('    ' + k + ": " + properties[k])
                changePageDone()
                _deletePages(deletingPages)
                return null
            }

            var ret = page.pageSkip()
            filename = ret["page"]
            // remember to destroy all the pages we have created in the meanwhile
            if (filename !== "") {
                deletingPages.push(page)
            }
            properties = ret["properties"]
        }
    }

    pushPage(page)
    _deletePages(deletingPages)
    return page
}

function currentPage() {
    return stack[stack.length - 1]
}

function transitionAfterPush() {
    var out_index = stack.length - 2
    var in_index = stack.length - 1
    if (out_index >= 0)
        stack[out_index].pushOutStart()
    if (in_index >= 0)
        stack[in_index].pushInStart()
}

function transitionBeforePop(target_index) {
    var out_index = stack.length - 1
    var in_index = target_index

    if (out_index >= 0)
        stack[out_index].popOutStart()
    if (in_index >= 0)
        stack[in_index].popInStart()
}

function pushPage(page) {
    stack.push(page)
    current_index = stack.length - 1;
    if (stack.length > 1)
        transitionAfterPush()
}

function showPreviousPage(index) {
    if (changing_page == true)
        return

    changing_page = true

    stack[index].visible = true
    transitionBeforePop(index)
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

        if (i > current_index)
            stack[i].destroy()
    }
    stack.length = current_index + 1
    changing_page = false
}

