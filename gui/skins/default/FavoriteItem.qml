import QtQuick 1.1
import "js/Stack.js" as Stack

Item {
    id: favoriteItem
    property alias imageSource: icon.source
    property alias text: label.text
    property string address: "www.corriere.it"

    signal requestEdit(variant favorite)

    property int additionalWidth: 10
    width: column.width + 10
    height: column.height + 10

    Column {
        id: column

        spacing: 10
        Rectangle {
            id: highlight
            width: icon.width + favoriteItem.additionalWidth
            height: icon.height + favoriteItem.additionalWidth
            gradient: Gradient {
                GradientStop {
                    position: 0.00;
                    color: "#b7b7b7";
                }
                GradientStop {
                    position: 1.00;
                    color: "#ffffff";
                }
            }
            Behavior on width {
                NumberAnimation { target: highlight; property: "width"; duration: 200; easing.type: Easing.InOutQuad }
            }
            Behavior on height {
                NumberAnimation { target: highlight; property: "height"; duration: 200; easing.type: Easing.InOutQuad }
            }

            Image {
                id: icon
                anchors.centerIn: parent
                source: "images/profiles/web.png"
            }
        }

//        Text {
//            id: label
//            anchors.horizontalCenter: parent.horizontalCenter
//            text: "Testo molto molto molto lungo"
//            horizontalAlignment: Text.AlignHCenter
//            width: icon.width
//            wrapMode: Text.Wrap
//            maximumLineCount: 2
//            elide: Text.ElideRight
//        }

        TextInput {
            id: label
            onActiveFocusChanged: {
                console.log("Edit completed")
            }

            anchors.horizontalCenter: parent.horizontalCenter
            text: "Corriere.it - Il sito web del Corriere della Sera"
            horizontalAlignment: Text.AlignHCenter
            width: icon.width

            activeFocusOnPress: false
        }
    }

    Column {
        id: editColumn
        opacity: 0
        anchors.left: column.right

        Rectangle {
            color: "#6d6c6c"
            width: 48
            height: 48
            Image {
                source: "images/icon_text.png"
                anchors.fill: parent
                anchors.margins: 10
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    label.forceActiveFocus()
                    label.openSoftwareInputPanel()
                }
            }
        }

        Rectangle {
            color: "#6d6c6c"
            width: 48
            height: 48
            Image {
                source: "images/icon_pencil.png"
                anchors.fill: parent
                anchors.margins: 10
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    console.log("Clicked on edit icon")
                    favoriteItem.requestEdit(favoriteItem)
                }
            }
        }

        Rectangle {
            color: "#6d6c6c"
            width: 48
            height: 48
            Image {
                source: "images/icon_trash.png"
                anchors.fill: parent
                anchors.margins: 10
            }
        }

        Behavior on opacity {
            NumberAnimation { target: editColumn; property: "opacity"; duration: 200;}
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onPressAndHold: parent.state = "selected"
        onClicked: {
            Stack.openPage("Browser.qml", {'urlString': "http://" + address})
        }
        // TODO: just for debugging purposes
        onPressed: parent.state = ""
    }

    states: State {
        name: "selected"
        PropertyChanges {
            target: column
            anchors.margins: 0
        }
        PropertyChanges {
            target: favoriteItem
            additionalWidth: 20
        }
        PropertyChanges {
            target: editColumn
            opacity: 1
        }
    }
}
