// The containers for items and titles. Each item has its title, and the
// containers has always the same size.
Qt.include("logging.js")

var stackObjects = []

function loadComponent(menuLevel, component, title, dataModel, properties) {
    // checks if an operation is in progress and exit in case
    if (pendingOperations.length > 0)
        return

    // We need to pass the dataModel as a variant (because we use it in a signal),
    // but in the end the property is a QtObject. To avoid warning about the type
    // we do this trick.
    if (dataModel === undefined)
        dataModel = null



    var titleObj = createComponent("MenuTitle.qml", {"text": title, "parent": elementsContainer, "opacity": 0})
    if (!titleObj) {
        console.log("Error on creating the MenuTitle component")
        return
    }

    properties = typeof properties !== 'undefined' ? properties : {}
    properties["menuLevel"] = menuLevel + 1
    properties["parent"] = elementsContainer
    properties["opacity"] = 0
    properties["y"] = titleObj.height
    properties["dataModel"] = dataModel
    properties["pageObject"] = pageObject

    // creates an object from the component
    // Here we assume that width for the given MenuColumn is set correctly to
    // the width of the children (which are assumed to be all the same width).
    // Unfortunately, we can't use childrenRect because that includes shadows.
    var itemObj = component.createObject(mainContainer, properties)

    var shadowObj = createComponent("MenuShadow.qml", {"parent": elementsContainer, "opacity": 0, "anchors.fill": itemObj})
    if (!shadowObj) {
        itemObj.destroy()
        titleObj.destroy()
        console.log("Error on creating the MenuShadow component")
        return
    }

    if (itemObj) {
        _addItem(itemObj, titleObj, shadowObj)
        itemObj.closeItem.connect(closeItem)
        itemObj.loadComponent.connect(loadComponent)
        return
    }
    else {
        console.log("Error on creating the Component: " + component)
        shadowObj.destroy()
        titleObj.destroy()
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

function closeItem(menuLevel) {
    if (pendingOperations.length > 0) // we are during an operation
        return

    if (menuLevel >= stackObjects.length) { // the item to close does not exists
        debugMsg("closeItem: nothing to do")
        return
    }

    mainContainer.interactive = false

    debugMsg("closeItem level to close: " + menuLevel)
    for (var i = stackObjects.length - 1; i >= menuLevel; i--) {
        pendingOperations.push({'id': OP_CLOSE, 'notifyChildDestroyed': true})
    }

    pendingOperations.push({'id': OP_UPDATE_UI})
    processOperations()
}


function _addItem(item, title, shadow) {
    mainContainer.interactive = false
    debugMsg("_addItem level: " + item.menuLevel)
    for (var i = stackObjects.length - 1; i >= item.menuLevel; i--) {
        pendingOperations.push({'id': OP_CLOSE, 'notifyChildDestroyed': false})
    }

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
    for (var i = 0; i < stackObjects.length; i++)
        stackObjects[i]['item'].z = 1 - i * 0.01

    if (op['id'] === OP_OPEN)
        _openItem()
    else if (op['id'] === OP_CLOSE)
        _closeItem()
    else if (op['id'] === OP_UPDATE_UI)
        _updateView()
}

var verticalOffset = 10
var horizontalOverlap = 1

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
    title.enableAnimation = false

    if (stackObjects.length === 0) {
        shadow.opacity = 1
        item.opacity = 1
        title.opacity = 1
    }
    else {
        var last_item = stackObjects[stackObjects.length - 1]['item']
        item.y = last_item.y + verticalOffset
        item.x = last_item.x - horizontalOverlap
        title.x = last_item.x
    }
    item.enableAnimation = true
    title.enableAnimation = true
}

function _openItem() {
    debugMsg('_openItem')

    var item = pendingOperations[0]['item']
    var title = pendingOperations[0]['title']
    var shadow = pendingOperations[0]['shadow']

    _setStartProps()
    if (stackObjects.length === 0) {
        elementsContainer.width = item.width
        _doOpenItem()
    }
    else {
        item.animationRunningChanged.connect(_doOpenItem)
        elementsContainer.width += item.width - horizontalOverlap

        var last_item = stackObjects[stackObjects.length - 1]['item']
        hideLine(last_item, RIGHT_TO_LEFT)

        title.opacity = 1
        item.opacity = 1
        shadow.opacity = 1
        item.x = last_item.x + last_item.width - horizontalOverlap
        title.x = last_item.x + last_item.width
    }
}

function _doOpenItem() {

    var item = pendingOperations[0]['item']
    if (item.animationRunning)
        return

    debugMsg('_doOpenItem')
    showLine(item, RIGHT_TO_LEFT)
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
    pendingOperations.shift()
    processOperations()
}

var RIGHT_TO_LEFT = 1
var LEFT_TO_RIGHT = 2

function hideLine(item, direction) {
    line.width = 0
    if (direction === RIGHT_TO_LEFT)
        line.x = item.x
    else
        line.x = item.x + item.width
}

function showLine(item, direction) {
    line.enableAnimation = false
    line.y = item.y - (line.height + 2) // 2 is a little space
    line.width = 0
    if (direction === RIGHT_TO_LEFT)
        line.x = item.x + item.width
    else
        line.x = item.x

    line.enableAnimation = true
    line.width = item.width
    line.x = item.x
}

function _closeItem() {
    debugMsg("_closeItem")
    var item = stackObjects[stackObjects.length - 1]['item']
    var title = stackObjects[stackObjects.length - 1]['title']
    hideLine(item, LEFT_TO_RIGHT)
    item.animationRunningChanged.connect(_doCloseItem)
    if (stackObjects.length > 1) {
        item.x = stackObjects[stackObjects.length - 2]['item'].x
        title.x = stackObjects[stackObjects.length - 2]['title'].x
    }
    else {
        item.x = 0
        title.x = 0
    }
    item.opacity = 0
    title.opacity = 0
}

function _doCloseItem() {
    var item = stackObjects[stackObjects.length -1]['item']
    if (item.animationRunning)
        return

    var title = stackObjects[stackObjects.length -1]['title']
    var shadow = stackObjects[stackObjects.length -1]['shadow']

    elementsContainer.width -= item.width
    item.destroy()
    title.destroy()
    shadow.destroy()
    stackObjects.length -= 1
    var last_item = stackObjects[stackObjects.length -1]['item']
    last_item.child = null
    if (pendingOperations[0]['notifyChildDestroyed'])
        last_item.childDestroyed()

    mainContainer.currentObject = last_item
    showLine(last_item, LEFT_TO_RIGHT)
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
