import QtQuick 1.0
import "ItemContainer.js" as Script


Item {
    id: container
    width: 600
    height: 400
    property int itemsLeftMargin: 20
    property int itemsSpacing: 0
    signal closed

    ButtonBack {
        id: backButton
        anchors.top: container.top
        anchors.left: container.left
        onClicked: closeItem()
    }

    function closeItem() {
        if (Script.stack.length > 1) {
            Script.stack[Script.stack.length - 1].visible = false;
            Script.stack.length -= 1;
            // update the ui
            showItems(calculateFirstVisible());
        }
        else
            container.closed()
    }

    function addItem(item, level) {
        if (level < 0)
            console.log('Error!')

        if (level - 1 < Script.stack.length) {
            for (var i = level -1; i < Script.stack.length; i++) {
                Script.stack[i].visible = false;
            }
            Script.stack.length = level - 1;
        }

        item.visible = true;
        item.y = 0
        item.parent = container
        Script.stack.push(item)

        showItems(calculateFirstVisible());
    }


    function calculateFirstVisible() {
        var first_element = 0;
        var items_width = 0;

        for (var i = Script.stack.length - 1; i >= 0; i--) {
            items_width += Script.stack[i].width;
            if (items_width > container.width) {
                first_element = i + 1;
                break;
            }
        }
        return first_element;
    }

    function showItems(first_element) {
        var x = backButton.x + backButton.width + container.itemsLeftMargin;
        for (var i = 0; i < Script.stack.length; i++) {
            if (i >= first_element) {
                Script.stack[i].x = x;
                Script.stack[i].visible = true;
                x += Script.stack[i].width + container.itemsSpacing;
            }
            else
                Script.stack[i].visible = false;
        }
    }
}


