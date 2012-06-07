import QtQuick 1.1
import Components 1.0

import "js/Stack.js" as Stack

BasePage {
    id: page
    property alias toolbar: toolbar

    ToolBar {
        id: toolbar
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        fontSize: 17
        onHomeClicked: Stack.backToHome()
    }
}
