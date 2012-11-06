import QtQuick 1.1

TextInput {
    // see BaseTextEdit
    property variant containerWidget

    onFocusChanged: {
        if (!containerWidget)
            return

        var pannable = parent.parent

        while (pannable) {
            if (pannable.setCursorContainerWidget) {
                pannable.setCursorContainerWidget(parent, focus, containerWidget)
                break;
            }
            pannable = pannable.parent
        }
    }
}
