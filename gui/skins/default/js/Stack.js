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

// stack of pages (when used)
var stack = []

// stack index of current page
var current_index = -1

// are we changing page?
var changing_page = false

// entering page (used as temp if there is a page to be destroyed)
var entering_page = undefined


/*****************************************************************************
  *
  * public API
  *
  ***************************************************************************/

// Create a QML object from a given filename and pushes it on the stack
function pushPage(filename, properties) {
    if (properties === undefined)
        properties = {"visible": false}
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

// empties the stack and opens the page passed in; plays push animations
function goToPage(filename, properties) {
    if (properties === undefined)
        properties = {}
    properties.visible = false

    var current = currentPage()
    var entering = _goPage(filename, properties)

    if (current._pageName !== entering._pageName) {
        current.pushOutStart()
        entering.pushInStart()
    }
    else
        changePageDone()

    return entering
}

// empties the stack and opens the page passed in; plays pop animations
function backToPage(filename, properties) {
    if (properties === undefined)
        properties = {}
    properties.visible = false

    var current = currentPage()
    var entering = _goPage(filename, properties)

    if (current._pageName !== entering._pageName) {
        current.popOutStart()
        entering.popInStart()
    }
    else
        changePageDone()

    return entering
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
function backToSystemOrHome() {
    var ret = _findTargetPage("Systems.qml")
    if (!ret)
        return

    // Handle the case of page skippers. If we only have one system and we
    // press back, using backToPage() will bring us to the same system.
    if (ret.filename === "Systems.qml")
        backToPage("Systems.qml")
    else
        backToHome()
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

    if (entering_page) {
        stack[0].visible = false
        stack[0].destroy()
        stack[0] = entering_page
        entering_page = undefined
    }

    for (var i = 0; i < stack.length; i++) {
        if (i !== current_index)
            stack[i].visible = false

        if (i > current_index)
            stack[i].destroy()
    }

    stack.length = current_index + 1

    changing_page = false

    logDebug("Opening page: " + stack[current_index]._pageName)
}


/*****************************************************************************
  *
  * private API
  *
  ***************************************************************************/

// goes to a page (without animations
function _goPage(filename, properties) {
    var current = currentPage()

    logDebug("_goPage(), new page name: " + _getName(filename))
    if (current && current._pageName === _getName(filename)) {
        if (current.closeAll) // closes all menus if closeAll is defined on page
            current.closeAll()
        return current
    }

    var page = _createPage(filename, properties)

    if (!page)
        return current

    entering_page = page

    page.visible = true
    current_index = 0

    return page
}

function _addPageName(filename, properties) {
    var page_name = _getName(filename)
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
    var current = currentPage()
    var page = _createPage(filename, properties)

    if (current && page && current._pageName === page._pageName) {
        page.destroy()
        return
    }

    if (page) {
        page.visible = true
        _pushPage(page)
    }

    return page
}

// Find the name of the page to open, considering any skippers
//
// \return Undefined if maximum skip steps was reached or an object with the following properties:
//      - "filename": the path of the page to open
//      - "properties": the properties to pass to the page

function _findTargetPage(filename, properties) {
    var deletingObjects = []
    var parachute = 0
    var page_filename = ""

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
        page_filename = filename
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
            return undefined
        }
    }

    _deleteObjects(deletingObjects)
    return {'filename': page_filename, 'properties': properties}
}

// Create a QML object from a given filename
function _createPage(filename, properties) {
    if (changing_page == true)
        return null

    if (stack.length > 0)
        changing_page = true

    var ret = _findTargetPage(filename, properties)
    if (!ret)
        return null
    filename = ret.filename
    properties = ret.properties

    // now, Stack.js is in a js subdir so we have to trick the filename
    var page_component = Qt.createComponent("../" + filename)
    // The component status (like the Component.Ready that has 1 as value) is not currently
    // available on js files that uses .pragma library declaration.
    // This should be fixed in the future:
    // http://lists.qt.nokia.com/pipermail/qt-qml/2010-November/001713.html
    if (page_component.status === 1) {
        // Properly set _pageName
        _addPageName(filename, properties)
        var page = page_component.createObject(mainContainer, properties)
        if (page === null) {
            logError('Error on creating the object for the page: ' + filename)
            logError('Properties:')
            for (var k in properties)
                logError('    ' + k + ": " + properties[k])
            changePageDone()
            return null
        }
        logDebug("_createPage(), created page: " + page._pageName)
    }
    // Component.Error
    else if (page_component.status === 3) {
        logError("Error in creating page component: ")
        logError(page_component.errorString())
        changePageDone()
        return null
    }

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

function _getName(filename) {
    return filename.split('.')[0]
}

function __logStack__() {
    console.log("__________________________ __logStack__ _____________________________")
    console.log("stack: "+stack)
    console.log("length: "+stack.length)
    for (var i = 0; i < stack.length; ++i) {
        console.log(i+": "+stack[i])
    }
}
