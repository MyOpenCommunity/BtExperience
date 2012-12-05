import QtQuick 1.0

// assumes that it only has one child, and the child is a Flickable
//
// when the on-screen keyboard is displayed, move the flickable content so the
// input cursor is entirely on-screen and (if necessary) move the flickable upwards
// so the input field is not obscured by the on-screen keyboard
//
// see also BaseTextInput and BaseTextEdit
Item {
    // bind this property to the .y property of the Flickable child
    property real childOffset: 0.0
    property bool keyboardVisible: false
    property Item contentItem: children[0]

    property int keyboardTop
    property int keyboardHeight

    // cursor top/bottom relative to Pannable
    property double mappedVisibleTop
    property double mappedVisibleBottom

    property Item focusedItem
    property Item focusedWidget

    id: container
    clip: true

    Connections {
        target: global.inputWrapper.inputContext
        onInputMethodAreaChanged: {
            var cursor = global.inputWrapper.cursorRect

            // On the touch (probably depends on Qt version rather than environemnt),
            // we get a first input method area change event with
            // non-empty region when the cursor rect is still empty, and then another
            // one with cursor rect set; ignore the first one
            if (cursor.y === 0 && cursor.height === 0 && region.height !== 0)
                return

            // do not reposition the content to avoid the pop-up accented letter: since the
            // box does not cover the width of the screen, moving the content to avoid it looks
            // ugly (it could be handled separately, but it's not worth the trouble at the moment)
            if (keyboardVisible && region.height !== 0)
                return

            setKeyboardRect(region)
            updateCursorRect()
        }
        // We silent the warnings because the signal inputMethodAreaChanged exist only
        // when Mailiit is installed as input context.
        ignoreUnknownSignals: true
    }

    // Temporary workaround for focus handling: the mouse area below is resized to the same size as the
    // on-screen keyboard.
    //
    // For some reason, when the keyboard is used in the browser process, the url bar loses
    // focus after clicking the first letter, and the focus goes to the web view; it seems that
    // somehow the web view gets the mouse event even if it is handled by the keyboard, and steals
    // the focus from the url input.  This does not happen with the same web view hosted in
    // main BtExperience process.
    MouseArea {
        id: blockClicks
        z: 1
        enabled: false
    }

    // sets the area covered by the keyboard, in screen coordinates
    function setKeyboardRect(rect) {
        var mapped = mapFromItem(null, 0, rect.y)

        keyboardHeight = height - mapped.y
        keyboardTop = mapped.y
        keyboardVisible = rect.height !== 0

        if (!keyboardVisible) {
            childOffset = 0.0
            mappedVisibleTop = mappedVisibleBottom = 0
        }

        blockClicks.visible = keyboardVisible
        blockClicks.height = rect.height
        blockClicks.width = rect.width
        blockClicks.x = rect.x
        blockClicks.y = rect.y
    }

    // sets the area used by the input cursor, in screen coordinates
    function updateCursorRect() {
        var OFFSET = 10.0 // arbitrary border between the widget border and the input field

        var rect = global.inputWrapper.cursorRect
        var mappedTop = mapFromItem(null, rect.x, rect.y)
        var mappedBottom = mapFromItem(null, rect.x, rect.y + rect.height)

        if (focusedWidget) {
            // assumption: cursor is always inside the focus widget, othervise implement rectangle union
            var fwTop = mapFromItem(focusedWidget.parent, focusedWidget.x, focusedWidget.y)

            rect = Qt.rect(fwTop.x, fwTop.y, focusedWidget.width, focusedWidget.height)
            mappedTop.y = fwTop.y
            mappedBottom.y = fwTop.y + focusedWidget.height
        }

        var newMappedVisibleTop = mappedTop.y - OFFSET
        var newMappedVisibleBottom = mappedBottom.y + OFFSET

        if (keyboardVisible && (newMappedVisibleTop !== mappedVisibleTop || newMappedVisibleBottom !== mappedVisibleBottom)) {
            mappedVisibleTop = newMappedVisibleTop
            mappedVisibleBottom = newMappedVisibleBottom
            ensureCursorVisible()
        }
    }

    function ensureCursorVisible() {
        var delta = 0

        // handle Flickable content with the input field partially scrolled outside the item
        if (contentItem.contentY !== undefined) {
            var mappedTop = mapToItem(contentItem, 0, mappedVisibleTop)
            var mappedBottom = mapToItem(contentItem, 0, mappedVisibleBottom)

            // if the input field is partially outside the screen, move it into view;
            // this is not rolled back when the keyboard is hidden
            if (mappedTop.y + contentItem.contentY < 0)
                delta = mappedTop.y
            else if (mappedBottom.y + contentItem.contentY > height)
                delta = mappedBottom.y - height

            contentItem.contentY += delta
            mappedVisibleTop -= delta
            mappedVisibleBottom -= delta
        }
        // if the input field is covered by the keyboard, move the entire widget
        // upwards se the input field is visible
        if (mappedVisibleBottom > keyboardTop)
            childOffset -= mappedVisibleBottom - keyboardTop
    }

    // since the cursor position is not a property, it's necessary to poll it for changes
    Timer {
        id: pollCursor
        interval: 2000
        repeat: true
        running: keyboardVisible

        property int lastTop

        onTriggered: {
            var y = global.inputWrapper.cursorRect.y

            if (lastTop !== y)
                updateCursorRect()
            lastTop = y
        }
    }

    function setCursorContainerWidget(item, focus, widget) {
        if (!focus && focusedItem === item) {
            focusedItem = null
            focusedWidget = null
        } else if (focus) {
            focusedItem = item
            focusedWidget = widget

            if (keyboardVisible)
                updateCursorRect()
        }
    }
}
