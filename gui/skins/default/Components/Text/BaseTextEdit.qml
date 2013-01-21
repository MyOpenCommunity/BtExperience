import QtQuick 1.1

TextEdit {
    // this property is used together with Pannable; when the input field is
    // contained in a bigger item with additional controls (for example Ok/Cancel
    // buttons), setting this property ensures that the whole containerWidget is visible
    // above the keyboard
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
