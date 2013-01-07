import QtQuick 1.1

Item {
    id: itemLoader
    property Item item: null

    function setComponent(component, properties) {
        properties = properties || {}
        if (component === undefined) {
            if (item !== null)
                item.destroy()
            item = null
        }
        else {
            item = component.createObject(itemLoader, properties)
            itemLoader.width = item.width
            itemLoader.height = item.height
        }
    }
}
