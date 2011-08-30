// The containers for items and titles. Each item has its title, and the
// containers has always the same size.
var stackItems = []
var stackTitles = []

function closeItem() {
    if (stackItems.length > 1) {
        destroyLast(stackItems)
        destroyLast(stackTitles)
        stackItems[stackItems.length - 1].child = null
        stackItems[stackItems.length - 1].childDestroyed();

        // update the ui
        showItems(calculateFirstVisible());
    }
    else
        container.closed()
}

function loadComponent(menuLevel, childTitle, fileName) {
    var object = createComponent(fileName)
    var title = createComponent("MenuTitle.qml")
    if (object && title) {
        object.menuLevel = menuLevel + 1
        title.text = childTitle
        addItem(object, title)
        object._loadComponent.connect(loadComponent)
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

    item.visible = true;
    item.y = backButton.y
    item.parent = container

    if (stackItems.length >= 1) {
        stackItems[stackItems.length - 1].child = item
        stackItems[stackItems.length - 1].childLoaded()
    }
    stackItems.push(item)
    stackTitles.push(title)
    showItems(calculateFirstVisible());
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
function createComponent(fileName) {
    var component = Qt.createComponent(fileName)
    var object = null
    if (component.status == Component.Ready) {
        object = component.createObject(container)
        if (object == null)
            console.log('Error on creating the object for the component: ' + fileName)
    }
    else
        console.log('Error loading the component: ' + fileName)

    return object
}
