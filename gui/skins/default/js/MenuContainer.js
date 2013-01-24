// The containers for items and titles. Each item has its title, and the
// containers has always the same size.
Qt.include("logging.js")

var stackObjects = []

var debugTiming
var horizontalOverlap = 1

function loadComponent(menuLevel, component, title, dataModel, properties) {
    // checks if an operation is in progress and exit in case
    if (pendingOperations.length > 0)
        return

    debugTiming.logTiming("loadComponent start")
    // We need to pass the dataModel as a variant (because we use it in a signal),
    // but in the end the property is a QtObject. To avoid warning about the type
    // we do this trick.
    if (dataModel === undefined)
        dataModel = null

    properties = typeof properties !== 'undefined' ? properties : {}
    properties["menuLevel"] = menuLevel + 1
    properties["parent"] = elementsContainer
    properties["opacity"] = 0
    // The magic number in Constants.qml
    properties["y"] = 33
    properties["dataModel"] = dataModel
    properties["pageObject"] = pageObject

    // creates an object from the component
    // Here we assume that width for the given MenuColumn is set correctly to
    // the width of the children (which are assumed to be all the same width).
    // Unfortunately, we can't use childrenRect because that includes shadows.
    var itemObj = component.createObject(mainContainer, properties)
    if (!itemObj) {
        console.log("Error on creating the Component: " + component + "error: " + component.errorString())
        return
    }

    var shadowObj = createComponent("MenuShadow.qml", {"parent": elementsContainer, "opacity": 0, "anchors.fill": itemObj})
    if (!shadowObj) {
        itemObj.destroy()
        console.log("Error on creating the MenuShadow component")
        return
    }

    var titleObj = createComponent("MenuTitle.qml", {"text": title, "parent": elementsContainer,
                                       "anchors.left": itemObj.left, "anchors.leftMargin": horizontalOverlap,
                                       "anchors.bottom": itemObj.top, "anchors.bottomMargin": 2, "menuColumn": itemObj})
    if (!titleObj) {
        itemObj.destroy()
        shadowObj.destroy()
        console.log("Error on creating the MenuTitle component")
        return
    }

    if (itemObj) {
        var ma = createComponent("MenuColumnMouseArea.qml", {"parent": elementsContainer, "anchors.fill": itemObj, "z": -1})
        itemObj.closeItem.connect(closeItem)
        // We cannot directly connect to the destroy() method, it seems because
        // it's not a 'proper' javascript function. In fact, defining a
        // myDestroy() function inside the object works fine.
        // Use a Connections object to be more declarative.
        shadowObj.menuColumn = itemObj
        ma.menuColumn = itemObj
        itemObj.loadComponent.connect(loadComponent)
        debugTiming.logTiming("Done creating MenuColumn")
        _addItem(itemObj, titleObj, shadowObj)
    }
}

var OP_CLOSE = 1
var OP_OPEN = 2
var OP_UPDATE_UI = 3

var pendingOperations = []

var transitionDebug = false


function closeLastItem() {
    if (pendingOperations.length > 0) // we are during an operation
        return

    mainContainer.interactive = false

    debugMsg("closeLastItem")
    if (stackObjects.length > 1) {
        pendingOperations.push({'id': OP_CLOSE, 'notifyChildDestroyed': true})
        pendingOperations.push({'id': OP_UPDATE_UI})
        processOperations()
    }
    else
    {
        // this shouldn't be necessary at all right now, since the closed() will
        // trigger object destruction, but I don't want to have surprises if
        // we change the semantics later on
        mainContainer.interactive = true
        mainContainer.closed()
    }
}

var NOTIFY_CHILD_DESTROYED = true

function closeItem(menuLevel) {
    if (pendingOperations.length > 0) // we are during an operation
        return

    if (menuLevel >= stackObjects.length) { // the item to close does not exists
        debugMsg("closeItem: nothing to do")
        return
    }

    mainContainer.interactive = false

    debugMsg("closeItem level to close: " + menuLevel)
    _closeItems(menuLevel, NOTIFY_CHILD_DESTROYED)

    pendingOperations.push({'id': OP_UPDATE_UI})
    processOperations()
}

function _closeItems(targetLevel, notifyChildDestroyed) {
    notifyChildDestroyed = notifyChildDestroyed || false
    var removingObjectsWidth = 0
    for (var i = stackObjects.length - 1; i >= targetLevel; i--) {
        // Here we must remember to update the UI once in a while to avoid that
        // the menus are closed behind the clipping container.
        // Example: enter the energy goal settings, then click on the alarm
        // clock in the toolbar
        removingObjectsWidth += stackObjects[i].item.width
        if (removingObjectsWidth > mainContainer.width) {
            debugMsg("Removing width of elements is too much, adding an UPDATE_UI op")
            pendingOperations.push({'id': OP_UPDATE_UI})
            removingObjectsWidth = 0
        }
        pendingOperations.push({'id': OP_CLOSE, 'notifyChildDestroyed': notifyChildDestroyed})
    }
}

function _addItem(item, title, shadow) {
    debugTiming.logTiming("_addItem start")
    mainContainer.interactive = false
    debugMsg("_addItem level: " + item.menuLevel)
    _closeItems(item.menuLevel)

    pendingOperations.push({'id': OP_UPDATE_UI, 'newItem': item})
    pendingOperations.push({'id': OP_OPEN, 'item': item, 'title': title, 'shadow': shadow})
    processOperations()
}

function processOperations() {

    debugMsg('processOperations -> operations pending: ' + pendingOperations.length)

    if (pendingOperations.length  === 0) {
        mainContainer.interactive = true
        return
    }

    var op = pendingOperations[0]

    // To show the new item from behind (and to hide in the same way)
    for (var i = 0; i < stackObjects.length; i++) {
        stackObjects[i]['item'].z = 1 - i * 0.01
        stackObjects[i]['shadow'].z = 1 - i * 0.01
    }

    if (op['id'] === OP_OPEN)
        _openItem()
    else if (op['id'] === OP_CLOSE)
        _closeItem()
    else if (op['id'] === OP_UPDATE_UI)
        _updateView()
}

var verticalOffset = 10

function _calculateFirstElement(starting_width) {
    var first_element = 0
    var items_width = starting_width

    var max_width = mainContainer.width

    for (var i = stackObjects.length - 1; i >= 0; i--) {
        items_width += stackObjects[i]['item'].width
        if (items_width > max_width) {
            first_element = i + 1
            break
        }
    }
    return first_element
}

function _updateView() {
    debugMsg('_updateView')
    var item = pendingOperations[0]['newItem']

    var starting_width = item ? item.width : 0
    var first_item = _calculateFirstElement(starting_width)

    var starting_x = 0
    for (var i = 0; i < first_item; i++) {
        starting_x += stackObjects[i]['item'].width // - horizontalOverlap
    }
    debugMsg('starting x: ' + starting_x)

    if (elementsContainer.x === -starting_x) {
        pendingOperations.shift()
        processOperations()
        return
    }

    elementsContainer.animationRunningChanged.connect(_doUpdateView)
    elementsContainer.x = - starting_x
}

function _doUpdateView() {
    if (elementsContainer.animationRunning)
        return

    debugMsg('_doUpdateView')
    elementsContainer.animationRunningChanged.disconnect(_doUpdateView)

    pendingOperations.shift()
    processOperations()
}

function _setStartProps() {
    var item = pendingOperations[0]['item']
    var title = pendingOperations[0]['title']
    var shadow = pendingOperations[0]['shadow']

    item.enableAnimation = false

    if (stackObjects.length === 0) {
        shadow.opacity = 1
        item.opacity = 1
        title.opacity = 1
    }
    else {
        var last_item = stackObjects[stackObjects.length - 1]['item']
        item.y = last_item.y + verticalOffset
        item.x = last_item.x - horizontalOverlap
        var last_title = stackObjects[stackObjects.length - 1]['title']
        title.y = last_title.y + verticalOffset
    }
    item.enableAnimation = true
}

function _openItem() {
    debugMsg('_openItem')

    var item = pendingOperations[0]['item']
    var title = pendingOperations[0]['title']
    var shadow = pendingOperations[0]['shadow']
    elementsContainer.currentLevel++

    _setStartProps()
    if (stackObjects.length === 0) {
        elementsContainer.width = item.width
        _doOpenItem()
    }
    else {
        item.animationRunningChanged.connect(_doOpenItem)
        elementsContainer.width += item.width - horizontalOverlap

        var last_item = stackObjects[stackObjects.length - 1]['item']

        title.opacity = 1
        item.opacity = 1
        shadow.opacity = 1
        item.x = last_item.x + last_item.width - horizontalOverlap
    }
}

function _doOpenItem() {

    var item = pendingOperations[0]['item']
    if (item.animationRunning)
        return

    debugMsg('_doOpenItem')
    var title = pendingOperations[0]['title']
    var shadow = pendingOperations[0]['shadow']

    item.animationRunningChanged.disconnect(_doOpenItem)

    if (stackObjects.length >= 1) {
        var last_item = stackObjects[stackObjects.length - 1]['item']
        last_item.child = item
        last_item.childLoaded()
    }

    stackObjects.push({'item': item, 'title': title, 'shadow': shadow})

    if (stackObjects.length === 1)
        mainContainer.rootObject = item

    mainContainer.currentObject = item
    debugTiming.logTiming("Open animation finished")
    pendingOperations.shift()
    processOperations()

    mainContainer.loadNextColumn() // see navigation.js for further details
}

function _closeItem() {
    debugMsg("_closeItem")
    var item = stackObjects[stackObjects.length - 1]['item']
    var title = stackObjects[stackObjects.length - 1]['title']
    item.animationRunningChanged.connect(_doCloseItem)
    if (stackObjects.length > 1) {
        item.x = stackObjects[stackObjects.length - 2]['item'].x
    }
    else {
        item.x = 0
    }
    item.opacity = 0
    title.opacity = 0
}

function _doCloseItem() {
    var item = stackObjects[stackObjects.length -1]['item']
    if (item.animationRunning)
        return

    elementsContainer.currentLevel--
    elementsContainer.width -= item.width
    item.destroy()
    stackObjects.length -= 1
    var last_item = stackObjects[stackObjects.length -1]['item']
    last_item.child = null
    if (pendingOperations[0]['notifyChildDestroyed'])
        last_item.childDestroyed()

    mainContainer.currentObject = last_item
    pendingOperations.shift()
    processOperations()
}


// Create and return a component or null if an error occurred
function createComponent(fileName, initData) {
    var component = Qt.createComponent(fileName)
    var object = null
    if (component.status === Component.Ready) {
        object = component.createObject(mainContainer, initData)
        if (object === null)
            logError('Error on creating the object for the component: ' + fileName)
    }
    else
        logError('Error loading the component: ' + fileName + ' error: ' + component.errorString())

    return object
}

function debugMsg(message) {
    if (transitionDebug)
        console.log(message)
}
