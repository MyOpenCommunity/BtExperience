
var itemComponent;
var item;

// TODO: when an item is showed the previous one is destroyed. Make it clear and
// add make the function more generic!
function showItem(componentFile, container) {
    if (item != null)
        item.destroy();

    console.log("component file:" + componentFile)
    itemComponent = Qt.createComponent(componentFile)
    if (itemComponent.status == Component.Ready) {
        item = itemComponent.createObject(container);
        if (item == null)
            console.log('error during the object creation')

        item.width = container.width;
        item.height = container.height;
        item.z = 1;
    }
    else {
        console.log('error during the object creation')
    }
}

