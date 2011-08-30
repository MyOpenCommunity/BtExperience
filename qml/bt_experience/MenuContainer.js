
var stack = []

function closeItem() {
    if (stack.length > 1) {
        stack[stack.length - 1].visible = false;
        stack[stack.length - 1].destroy();
        stack.length -= 1;

        stack[stack.length - 1].child = null
        stack[stack.length - 1].childDestroyed();

        // update the ui
        showItems(calculateFirstVisible());
    }
    else
        container.closed()
}

function loadComponent(menuLevel, fileName) {
    var component = Qt.createComponent(fileName)
    if (component.status == Component.Ready) {
        var object = component.createObject(container)
        if (object) {
            object.menuLevel = menuLevel + 1
            addItem(object)
            object._loadComponent.connect(loadComponent)
        }
        else
            console.log('Error on creating the object for the component: ' + fileName)
    }
    else
        console.log('Error loading the component: ' + fileName)
}

function addItem(item) {
    if (item.menuLevel < stack.length) {
        for (var i = item.menuLevel; i < stack.length; i++) {
            stack[i].visible = false;
            stack[i].destroy()
        }
        stack.length = item.menuLevel;
    }

    item.visible = true;
    item.y = 0
    item.parent = container

    if (stack.length >= 1) {
        stack[stack.length - 1].child = item
        stack[stack.length - 1].childLoaded()
    }
    stack.push(item)

    showItems(calculateFirstVisible());
}


function calculateFirstVisible() {
    var first_element = 0;
    var items_width = 0;

    for (var i = stack.length - 1; i >= 0; i--) {
        items_width += stack[i].width;
        if (items_width > container.width) {
            first_element = i + 1;
            break;
        }
    }
    return first_element;
}

function showItems(first_element) {
    var x = backButton.x + backButton.width + container.itemsLeftMargin;
    for (var i = 0; i < stack.length; i++) {
        if (i >= first_element) {
            stack[i].x = x;
            stack[i].visible = true;
            x += stack[i].width + container.itemsSpacing;
        }
        else
            stack[i].visible = false;
    }
}



