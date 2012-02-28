import QtQuick 1.1

QtObject {
    // time needed for a new column (MenuElement) to show up
    property int elementTransitionDuration: 400
    // time needed to show the line above the MenuElement
    property int lineTransitionDuration: elementTransitionDuration / 2
    // time needed to show an alert popup (termo, antintrusion ...)
    property int alertTransitionDuration: 200
}
