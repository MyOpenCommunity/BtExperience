// The containers for items and titles. Each item has its title, and the
// containers has always the same size.
var stackItems = []
var stackTitles = []


function updateUi() {
    showItems(calculateFirstVisible());
}

function closeLastItem() {
    if (stackItems.length > 1) {
        destroyLast(stackItems)
        destroyLast(stackTitles)
        stackItems[stackItems.length - 1].child = null
        stackItems[stackItems.length - 1].childDestroyed();
        updateUi()
    }
    else
        container.closed()
}

function closeItem(menuLevel) {
    if (menuLevel == 0) {
        console.log("Error: cannot close the root element! Use the closeLastItem instead.")
        return
    }

    while (menuLevel < stackItems.length) {
        destroyLast(stackItems)
        destroyLast(stackTitles)
    }
    stackItems[stackItems.length - 1].child = null
    stackItems[stackItems.length - 1].childDestroyed();
    updateUi()
}

function loadComponent(menuLevel, childTitle, fileName) {
    var object = createComponent(fileName, {"menuLevel": menuLevel + 1, "y": backButton.y, parent: container})
    var title = createComponent("MenuTitle.qml", {"text": childTitle, parent: container})
    if (object && title) {
        addItem(object, title)
        object._loadComponent.connect(loadComponent)
        object._closeElement.connect(closeItem)
    }
    // Cleanup the memory in case of errors
    else if (object) {
        object.destroy()
    }
    else if (title) {
        title.destroy()
    }
}

function addItem(item, title) {
    while (item.menuLevel < stackItems.length) {
        destroyLast(stackItems)
        destroyLast(stackTitles)
    }

    if (stackItems.length >= 1) {
        stackItems[stackItems.length - 1].child = item
        stackItems[stackItems.length - 1].childLoaded()
    }
    stackItems.push(item)
    stackTitles.push(title)
    updateUi()
}


function calculateFirstVisible() {
    var first_element = 0;
    var items_width = 0;

    var total_width = container.width - (backButton.x + backButton.width + container.itemsLeftMargin)

    for (var i = stackItems.length - 1; i >= 0; i--) {
        items_width += stackItems[i].width + container.itemsSpacing;
        if (items_width > total_width) {
            first_element = i + 1;
            break;
        }
    }
    return first_element;
}

function showItems(first_element) {
    var x = backButton.x + backButton.width + container.itemsLeftMargin;
    for (var i = 0; i < stackItems.length; i++) {
        if (i >= first_element) {
            stackItems[i].x = x;
            stackItems[i].visible = true
            stackTitles[i].x = x
            stackTitles[i].visible = true
            x += stackItems[i].width + container.itemsSpacing;
        }
        else {
            stackItems[i].visible = false
            stackTitles[i].visible = false
        }
    }
}


// Generic functions

// An utility function that destroys the last element from the container argument
function destroyLast(container) {
    container[container.length - 1].visible = false;
    container[container.length - 1].destroy();
    container.length -= 1;
}

// Create and return a component or null if an error occurred
function createComponent(fileName, initData) {
    var component = Qt.createComponent(fileName)
    var object = null
    if (component.status == Component.Ready) {
        object = component.createObject(container, initData)
        if (object == null)
            console.log('Error on creating the object for the component: ' + fileName)
    }
    else
        console.log('Error loading the component: ' + fileName)

    return object
}
