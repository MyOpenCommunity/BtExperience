import QtQuick 1.0
import "ItemContainer.js" as Script


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
            container.addItem(level5, 5)
        }
    }

    Loader {
        id: level5
    }
}


