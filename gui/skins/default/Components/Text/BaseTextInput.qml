import QtQuick 1.1

TextInput {
    // see BaseTextEdit
    property variant containerWidget

    onActiveFocusChanged: {
        if (containerWidget)
            propagateContainerWidget()
    }

    Component.onCompleted: {
        if (containerWidget && activeFocus)
            propagateContainerWidget()
    }

    function propagateContainerWidget() {
        var pannable = parent.parent

        while (pannable) {
            if (pannable.setCursorContainerWidget) {
                pannable.setCursorContainerWidget(parent, activeFocus, containerWidget)
                break;
            }
            pannable = pannable.parent
        }
    }
}
