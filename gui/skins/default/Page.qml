import QtQuick 1.1
import Components 1.0

import "js/Stack.js" as Stack

BasePage {
    property alias toolbar: toolbar

    ToolBar {
        id: toolbar
        fontFamily: semiBoldFont.name
        fontSize: 17
        onHomeClicked: Stack.backToHome()
    }
}
