// This declaration makes the javascript code share the execution context between
// different qml files.

.pragma library
Qt.include("logging.js")
Qt.include("MainContainer.js")

var stack = []

var current_index = -1

var changing_page = false


// Create a QML object from a given filename and push it on the stack
function openPage(filename, properties) {
    if (properties === undefined)
        properties = {}
    // automatically set _pageName from component filename
    _addPageName(properties, filename)
    return _openPage(filename, properties)
}

function _addPageName(props, filename) {
    var page_name = filename.split('.')[0]
    if (props['_pageName'] === undefined)
        props['_pageName'] = page_name
}

function _deletePages(list) {
    for (var i = 0; i < list.length; ++i)
        list[i].destroy()
}

function _skipperFilename(filename) {
    filename = "../Skippers/" + filename
    var dotPos = filename.lastIndexOf('.')
    return filename.slice(0, dotPos) + "Skipper.qml"
}

// Create a QML object from a given filename and push it on the stack
function _openPage(filename, properties) {
    if (changing_page == true)
        return

    if (stack.length > 0)
        changing_page = true

    var page = undefined
    var deletingObjects = []
    var parachute = 0

    // Implement the "page skip" functionality.
    //
    // We want to avoid creating the full page, which may be very complex, and
    // also the page skip functionality wasn't working before: we created the
    // page with a parent, so it was shown for a short time frame.
    //
    // When a page load is requested, we check for the corresponding Skipper
    // component in the Skippers/ subdirectory. This will create a temporary (and
    // simple) object with only one interface function: pageSkip().
    //
    // The returned object must have two properties: 'page' and 'properties'.
    //  "page": the filename of the page to be loaded instead. It must be a valid
    //     file path, in the same format accepted by Stack.openPage().
    //  "properties": the properties to set into the new page
    while (filename !== "") {
        var page_filename = filename
        logDebug("Trying to get skipper: " + _skipperFilename(filename))
        var skipper_component = Qt.createComponent(_skipperFilename(filename))
        deletingObjects.push(skipper_component)
        if (skipper_component.status === 1) {
            // the skipper is present and ready, use it
            var skipper = skipper_component.createObject(null)
            if (skipper === null) {
                logWarning("Could not create skipper object for page: " + filename)
                // terminate the loop anyway
                filename = ""
            }

            var ret = skipper.pageSkip()
            filename = ret["page"]
            deletingObjects.push(skipper)
            properties = ret["properties"]
        }
        else {
            logDebug("Page skipper not found: " + skipper_component.errorString())
            // terminate the loop
            filename = ""
        }

        ++parachute
        if (parachute >= 20) {
            logError("Maximum number skip pages reached, aborting")
            changePageDone()
            _deletePages(deletingObjects)
            return null
        }
    }

    // now, Stack.js is in a js subdir so we have to trick the filename
    logDebug("Trying to load page: " + "../" + page_filename)
    var page_component = Qt.createComponent("../" + page_filename)
    deletingObjects.push(page_component)
    // The component status (like the Component.Ready that has 1 as value) is not currently
    // available on js files that uses .pragma library declaration.
    // This should be fixed in the future:
    // http://lists.qt.nokia.com/pipermail/qt-qml/2010-November/001713.html
    if (page_component.status === 1) {
        // Properly set _pageName
        _addPageName(properties, page_filename)
        page = page_component.createObject(mainContainer, properties)
        if (page === null) {
            logError('Error on creating the object for the page: ' + filename)
            logError('Properties:')
            for (var k in properties)
                logError('    ' + k + ": " + properties[k])
            changePageDone()
            _deletePages(deletingObjects)
            return null
        }
    }
    // Component.Error
    else if (page_component.status === 3) {
        logError("Error in creating page component: ")
        logError(page_component.errorString())
        changePageDone()
        _deletePages(deletingObjects)
        return null
    }

    pushPage(page)
    _deletePages(deletingObjects)
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

// tries to remove count pages from the stack
// if count is bigger than the number of stack pages, removes all except the home
// if count is less or equal to zero does nothing
function popPages(count) {
    if (count <= 0) // nothing to do
        return

    if (count >= stack.length) {
        backToHome()
        return
    }

    showPreviousPage(stack.length - count - 1)
}

function backToHome() {
    showPreviousPage(0)
}

function changePageDone() {
    for (var i = 0; i < stack.length; i++) {
        if (i !== current_index)
            stack[i].visible = false

        if (i > current_index)
            stack[i].destroy()
    }
    stack.length = current_index + 1
    changing_page = false
}

