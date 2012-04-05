import QtQuick 1.0

// assumes that it only has one child, and the child is a Flickable
//
// when the on-screen keyboard is displayed, move the flickable content so the
// input cursor is entirely on-screen and (if necessary) move the flickable upwards
// so the input field is not obscured by the on-screen keyboard
Item {
    // bind this property to the .y property of the Flickable child
    property real childOffset: 0.0
    property bool keyboardVisible: false
    property Flickable contentItem: children[0]

    id: container
    clip: true

    Connections {
        target: global.inputWrapper.inputContext
        onInputMethodAreaChanged: {
            var cursor = global.inputWrapper.cursorRect;

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
            setCursorRect(cursor)
            setKeyboardVisible(region.height !== 0)
        }
    }

    // sets the area covered by the keyboard, in screen coordinates
    function setKeyboardRect(rect) {
        var mapped = mapFromItem(null, 0, rect.y)

        this.keyboardHeight = height - mapped.y
        this.keyboardTop = mapped.y
    }

    // sets the area used by the input cursor, in screen coordinates
    function setCursorRect(rect) {
        var OFFSET = 10.0 // arbitrary border between the widget border and the input field
        var mappedTop = mapFromItem(null, 0, rect.y - OFFSET)
        var mappedBottom = mapFromItem(null, 0, rect.y + rect.height + OFFSET)

        this.focusRect = {top: mappedTop.y, bottom: mappedBottom.y}
    }

    function setKeyboardVisible(visible) {
        var delta = 0

        keyboardVisible = visible

        if (!visible) {
            this.childOffset = 0.0

            return
        }

        // if the input field is partially outside the screen, move it into view;
        // this is not rolled back when the keyboard is hidden
        if (this.focusRect.top < 0)
            delta = this.focusRect.top;
        else if (this.focusRect.bottom > height)
            delta = this.focusRect.bottom - height

        contentItem.contentY += delta
        this.focusRect.top -= delta
        this.focusRect.bottom -= delta

        // if the input field is covered by the keyboard, move the entire widget
        // upwards se the input field is visible
        if (this.focusRect.bottom > this.keyboardTop)
            this.childOffset -= this.focusRect.bottom - this.keyboardTop
    }
}
