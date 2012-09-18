// This declaration makes the javascript code share the execution context between
// different qml files.
.pragma library


Qt.include("logging.js")
Qt.include("MainContainer.js")


/*****************************************************************************
  *
  * variables
  *
  ***************************************************************************/
var stack = []

var current_index = -1

var changing_page = false

var entering_page = undefined


/*****************************************************************************
  *
  * public API
  *
  ***************************************************************************/

// Create a QML object from a given filename and pushes it on the stack
function pushPage(filename, properties) {
    if (properties === undefined)
        properties = {}
    // automatically set _pageName from component filename
    _addPageName(filename, properties)
    return _openPage(filename, properties)
}

// pops a page from the stack; if only one page remains, returns to home page
function popPage() {
    if (stack.length > 1) {
        _showPreviousPage(stack.length - 2)
        return
    }

    if (stack.length === 1)
        backToHome()
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

    _showPreviousPage(stack.length - count - 1)
}

// empties the stack and opens the page passed in; plays push animations
function goToPage(filename, properties) {
    if (properties === undefined)
        properties = {}
    var current = currentPage()
    _goPage(filename, properties)
    if (current)
        current.pushOutStart()
    if (entering_page)
        entering_page.pushInStart()
    return entering_page
}

// empties the stack and opens the page passed in; plays pop animations
function backToPage(filename, properties) {
    if (properties === undefined)
        properties = {}
    var current = currentPage()
    _goPage(filename, properties)
    if (current)
        current.popOutStart()
    if (entering_page)
        entering_page.popInStart()
    return entering_page
}

// returns a reference to current page
function currentPage() {
    return stack[stack.length - 1]
}

// returns to home page
function backToHome() {
    backToPage("HomePage.qml")
}

// returns to systems page
function backToSystem() {
    backToPage("Systems.qml")
}

// returns to rooms page
function backToRoom() {
    backToPage("Rooms.qml")
}

// returns to multimedia page
function backToMultimedia() {
    backToPage("Multimedia.qml")
}

// returns to options page
function backToOptions() {
    backToPage("Settings.qml")
}

// called when transitions end, it must set right stack state
function changePageDone() {
    // This function is called twice on each page change, small optimization
    if (!changing_page)
        return

    // if entering_page is undefined we are in push/pop case
    if (entering_page === undefined) {
        for (var i = 0; i < stack.length; i++) {
            if (i !== current_index)
                stack[i].visible = false

            if (i > current_index)
                stack[i].destroy()
        }

        stack.length = current_index + 1
    }

    changing_page = false
    entering_page = undefined

    logDebug("Opening page: " + stack[current_index]._pageName)
}


/*****************************************************************************
  *
  * private API
  *
  ***************************************************************************/

// goes to a page (without animations
function _goPage(filename, properties) {
    var page = _createPage(filename, properties)
    var current = currentPage()

    if (current && current._pageName === page._pageName) {
        if (page.closeAll) // closes all menus if closeAll is defined on page
            page.closeAll()
        return
    }

    if (current)
        stack[0] = page
    else
        stack.push(page)

    current_index = 0
    entering_page = page
}

function _addPageName(filename, properties) {
    var page_name = filename.split('.')[0]
    if (properties['_pageName'] === undefined)
        properties['_pageName'] = page_name
}

function _deleteObjects(list) {
    for (var i = 0; i < list.length; ++i)
        list[i].destroy()
}

// Retrieve the Skipper file path
//
// Conventionally, Skipper components are located in the Skippers/ directory
// and the 'Skipper' suffix is added to the given page file name.
// Example: The page skipper for 'Systems.qml' page is called 'SystemsSkipper.qml'
function _skipperFilename(filename) {
    filename = "../Skippers/" + filename
    var dotPos = filename.lastIndexOf('.')
    return filename.slice(0, dotPos) + "Skipper.qml"
}

// Create a QML object from a given filename and push it on the stack
function _openPage(filename, properties) {
    var page = _createPage(filename, properties)

    _pushPage(page)

    return page
}

// Create a QML object from a given filename
function _createPage(filename, properties) {
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
        var skipper_component = Qt.createComponent(_skipperFilename(filename))
        if (skipper_component.status === 1) {
            logDebug("Found page skipper: " + _skipperFilename(filename))
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
            // terminate the loop
            filename = ""
        }

        ++parachute
        if (parachute >= 20) {
            logError("Maximum number skip pages reached, aborting")
            changePageDone()
            _deleteObjects(deletingObjects)
            return null
        }
    }

    // now, Stack.js is in a js subdir so we have to trick the filename
    var page_component = Qt.createComponent("../" + page_filename)
    // The component status (like the Component.Ready that has 1 as value) is not currently
    // available on js files that uses .pragma library declaration.
    // This should be fixed in the future:
    // http://lists.qt.nokia.com/pipermail/qt-qml/2010-November/001713.html
    if (page_component.status === 1) {
        // Properly set _pageName
        _addPageName(page_filename, properties)
        page = page_component.createObject(mainContainer, properties)
        if (page === null) {
            logError('Error on creating the object for the page: ' + filename)
            logError('Properties:')
            for (var k in properties)
                logError('    ' + k + ": " + properties[k])
            changePageDone()
            _deleteObjects(deletingObjects)
            return null
        }
    }
    // Component.Error
    else if (page_component.status === 3) {
        logError("Error in creating page component: ")
        logError(page_component.errorString())
        changePageDone()
        _deleteObjects(deletingObjects)
        return null
    }

    _deleteObjects(deletingObjects)

    return page
}

function _transitionAfterPush() {
    var out_index = stack.length - 2
    var in_index = stack.length - 1
    if (out_index >= 0)
        stack[out_index].pushOutStart()
    if (in_index >= 0)
        stack[in_index].pushInStart()
}

function _transitionBeforePop(target_index) {
    var out_index = stack.length - 1
    var in_index = target_index

    if (out_index >= 0)
        stack[out_index].popOutStart()
    if (in_index >= 0)
        stack[in_index].popInStart()
}

function _pushPage(page) {
    stack.push(page)
    current_index = stack.length - 1;
    if (stack.length > 1)
        _transitionAfterPush()
}

function _showPreviousPage(index) {
    if (changing_page == true)
        return

    changing_page = true

    stack[index].visible = true
    _transitionBeforePop(index)
    current_index = index
}
