import QtQuick 1.0
import "ItemContainer.js" as Script

// The ItemContainer components encapsulates some logic to show a tree of
// items. Using the itemsLeftMargin you can control the spacing between the
// back button and the root element, while using the itemsSpacing you can control
// the spacing between items.
// Every item must emit the signal loadComponent(string fileName) to request
// the loading of a child, and can implement the hook function reset(), called
// when a child is closed.

Item {
    id: container
    width: 600
    height: 400
    property int itemsLeftMargin: 20
    property int itemsSpacing: 0
    property string rootElement
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
            if (Script.stack[Script.stack.length - 1].item.reset)
                Script.stack[Script.stack.length - 1].item.reset();
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

// This probably works with QtQuick 1.1 ... check this code when the QtQuick is out!
//    Component.onCompleted: {
//        loaders.itemAt(0).source = container.rootElement
//        addItem(loaders.itemAt(0), 1)
//    }

//    Repeater {
//        id: loaders
//        model: container.numItems
//        Loader {
//            onLoaded: item.loadComponent.connect(loadComponent)
//            function loadComponent(fileName) {
//                console.log("Livello 1 Richiede di caricare: "+ fileName)
//                // destroy the previus item and load the new one
//                loaders.itemAt(index + 1).source = ""
//                loaders.itemAt(index + 1).source = fileName
//                container.addItem(loaders.itemAt(index + 1), index + 1)
//            }
//        }
//    }

    Component.onCompleted: {
        level1.source = container.rootElement
        if (level1.item)
            addItem(level1, 1)
    }

    Loader {
        id: level1
        onLoaded: item.loadComponent.connect(loadComponent)
        function loadComponent(fileName) {
            console.log("Livello 1 Richiede di caricare: "+ fileName)
            // destroy the previus item and load the new one
            level2.source = ""
            level2.source = fileName
            if (level2.item)
                container.addItem(level2, 2)
        }
    }

    Loader {
        id: level2
        onLoaded: item.loadComponent.connect(loadComponent)
        function loadComponent(fileName) {
            console.log("Livello 2 Richiede di caricare: "+ fileName)
            level3.source = ""
            level3.source = fileName
            if (level3.item)
                container.addItem(level3, 3)
        }
    }

    Loader {
        id: level3
        onLoaded: item.loadComponent.connect(loadComponent)
        function loadComponent(fileName) {
            console.log("Livello 3 Richiede di caricare: "+ fileName)
            level4.source = ""
            level4.source = fileName
            if (level4.item)
                container.addItem(level4, 4)
        }
    }

    Loader {
        id: level4
        onLoaded: item.loadComponent.connect(loadComponent)
        function loadComponent(fileName) {
            console.log("Livello 4 Richiede di caricare: "+ fileName)
            level5.source = ""
            level5.source = fileName
            if (level5.item)
                container.addItem(level5, 5)
        }
    }

    Loader {
        id: level5
    }
}


