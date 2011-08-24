import QtQuick 1.0
import "Stack.js" as Stack

Page {
    id: page
    source: "systems/termoregolazione.jpg"

    ToolBar {
            id: toolbar
            onCustomClicked: Stack.backToHome()
    }
}
