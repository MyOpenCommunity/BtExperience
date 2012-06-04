import QtQuick 1.1
import "../js/MainContainer.js" as Container

Text {
    // This is going to spit a warning on application exit, but at that time
    // we don't really care
    font.family: Container.mainContainer.ubuntuLight.name
}
