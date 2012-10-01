import QtQuick 1.1
import Components.Messages 1.0

SystemPage {
    source: "images/messages.jpg"
    text: qsTr("messages")
    rootColumn: Component { MessagesItems { } }
}
