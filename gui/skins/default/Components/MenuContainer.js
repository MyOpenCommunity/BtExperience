// The containers for items and titles. Each item has its title, and the
// containers has always the same size.
Qt.include("../js/logging.js")

var stackItems = []
var stackTitles = []

function loadComponent(menuLevel, fileName, title, dataModel) {

    if (pendingOperations.length > 0) // we are during an operation
        return

    // We need to pass the dataModel as a variant (because we use it in a signal),
    // but in the end the property is a QtObject. To avoid warning about the type
    // we do this trick.
    if (dataModel === undefined)
        dataModel = null

    var itemObject = createComponent("../" + fileName, {"menuLevel": menuLevel + 1, "parent": elementsContainer,
                                                "opacity": 0, "y": 33, "dataModel": dataModel,
                                                "pageObject": pageObject})
    var titleObject = createComponent("MenuTitle.qml", {"text": title, "parent": elementsContainer, "opacity": 0})
    if (itemObject && titleObject) {
        _addItem(itemObject, titleObject)
        itemObject.closeItem.connect(closeItem)
        itemObject.loadComponent.connect(loadComponent)
    }
    // Cleanup the memory in case of errors
    else if (itemObject) {
        itemObject.destroy()
    }
    else if (titleObject) {
        titleObject.destroy()
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

    debugMsg("closeLastItem")
    if (stackItems.length > 1) {
        pendingOperations.push({'id': OP_CLOSE, 'notifyChildDestroyed': true})
        pendingOperations.push({'id': OP_UPDATE_UI})
        processOperations();
    }
    else
        mainContainer.closed()
}

function closeItem(menuLevel) {
    if (pendingOperations.length > 0) // we are during an operation
        return

    if (menuLevel >= stackItems.length) { // the item to close does not exists
        debugMsg("closeItem: nothing to do")
        return
    }

    debugMsg("closeItem level to close: " + menuLevel)
    for (var i = stackItems.length - 1; i >= menuLevel; i--) {
        pendingOperations.push({'id': OP_CLOSE, 'notifyChildDestroyed': true})
    }

    pendingOperations.push({'id': OP_UPDATE_UI})
    processOperations();
}


function _addItem(item, title) {
    debugMsg("_addItem level: " + item.menuLevel)
    for (var i = stackItems.length - 1; i >= item.menuLevel; i--) {
        pendingOperations.push({'id': OP_CLOSE, 'notifyChildDestroyed': false})
    }

    pendingOperations.push({'id': OP_UPDATE_UI, 'newItem': item})
    pendingOperations.push({'id': OP_OPEN, 'item': item, 'title': title})
    processOperations()
}

function processOperations() {

    debugMsg('processOperations -> operations pending: ' + pendingOperations.length)

    if (pendingOperations.length  === 0)
        return

    var op = pendingOperations[0]

    // Per far apparire il nuovo item da sotto (e farlo scomparire nello stesso modo)
    for (var i = 0; i < stackItems.length; i++)
        stackItems[i].z = 1 - i * 0.01

    if (op['id'] == OP_OPEN)
        _openItem()
    else if (op['id'] == OP_CLOSE)
        _closeItem()
    else if (op['id'] == OP_UPDATE_UI)
        _updateView();
}

var verticalOffset = 10
var horizontalOverlap = 1

function _calculateFirstElement(starting_width) {
    var first_element = 0
    var items_width = starting_width

    var max_width = mainContainer.width - mainContainer.x

    for (var i = stackItems.length - 1; i >= 0; i--) {
        items_width += stackItems[i].width + mainContainer.itemsSpacing;
        if (items_width > max_width) {
            first_element = i + 1
            break;
        }
    }
    return first_element;
}

function _updateView() {
    debugMsg('_updateView')
    var item = pendingOperations[0]['newItem']

    var starting_width = item ? item.width : 0
    var first_item = _calculateFirstElement(starting_width)

    var starting_x = 0
    for (var i = 0; i < first_item; i++) {
        starting_x += stackItems[i].width + mainContainer.itemsSpacing // - horizontalOverlap
    }
    debugMsg('starting x: ' + starting_x)

    if (elementsContainer.x == -starting_x) {
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

    item.enableAnimation = false
    title.enableAnimation = false

    if (stackItems.length === 0) {
        item.opacity = 1
        title.opacity = 1
    }
    else {
        var last_item = stackItems[stackItems.length - 1]
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

    _setStartProps()
    if (stackItems.length === 0) {
        elementsContainer.width = item.width
        _doOpenItem()
    }
    else {
        item.animationRunningChanged.connect(_doOpenItem)
        elementsContainer.width += mainContainer.itemsSpacing + item.width - horizontalOverlap

        var last_item = stackItems[stackItems.length - 1]
        hideLine(last_item, RIGHT_TO_LEFT)

        title.opacity = 1
        item.opacity = 1
        item.x = last_item.x + last_item.width + mainContainer.itemsSpacing - horizontalOverlap
        title.x = last_item.x + last_item.width + mainContainer.itemsSpacing
    }
}

function _doOpenItem() {
    var item = pendingOperations[0]['item']
    if (item.animationRunning)
        return

    debugMsg('_doOpenItem')
    showLine(item, RIGHT_TO_LEFT)
    var title = pendingOperations[0]['title']
    item.animationRunningChanged.disconnect(_doOpenItem)

    if (stackItems.length >= 1) {
        stackItems[stackItems.length - 1].child = item
        stackItems[stackItems.length - 1].childLoaded()
    }

    stackItems.push(item)
    stackTitles.push(title)

    if (stackItems.length === 1)
        mainContainer.rootObject = item

    mainContainer.currentObject = item
    pendingOperations.shift()
    processOperations();
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
    line.y = item.y - 4
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
    var item = stackItems[stackItems.length - 1]
    var title = stackTitles[stackTitles.length - 1]
    hideLine(item, LEFT_TO_RIGHT)
    item.animationRunningChanged.connect(_doCloseItem)
    if (stackItems.length > 1) {
        item.x = stackItems[stackItems.length - 2].x
        title.x = stackTitles[stackTitles.length - 2].x
    }
    else {
        item.x = 0
        title.x = 0
    }
    item.opacity = 0
    title.opacity = 0
}

function _doCloseItem() {
    var item = stackItems[stackItems.length -1]
    if (item.animationRunning)
        return

    var title = stackTitles[stackTitles.length -1]

    elementsContainer.width -= item.width + mainContainer.itemsSpacing
    item.destroy()
    title.destroy()
    stackItems.length -= 1
    stackTitles.length -= 1
    var last_item = stackItems[stackItems.length -1]
    last_item.child = null
    if (pendingOperations[0]['notifyChildDestroyed'])
        last_item.childDestroyed();

    mainContainer.currentObject = last_item
    showLine(last_item, LEFT_TO_RIGHT)
    pendingOperations.shift()
    processOperations();
}


// Create and return a component or null if an error occurred
function createComponent(fileName, initData) {
    var component = Qt.createComponent(fileName)
    var object = null
    if (component.status == Component.Ready) {
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
