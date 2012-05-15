import QtQuick 1.1

Item {
    id: favoriteItem
    property alias imageSource: icon.source

    property int additionalWidth: 10
    width: column.width + 10
    height: column.height + 10

    Column {
        id: column

        spacing: 20
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

        Text {
            id: label
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Testo molto molto molto lungo"
            horizontalAlignment: Text.AlignHCenter
            width: icon.width
            wrapMode: Text.Wrap
            maximumLineCount: 2
            elide: Text.ElideRight
        }
    }

    MouseArea {
        anchors.fill: parent
        onPressAndHold: parent.state = "selected"
        onClicked: parent.state = ""
    }

    states: State {
        name: "selected"
        PropertyChanges {
            target: column
            anchors.margins: 0
        }
        PropertyChanges { target: favoriteItem; additionalWidth: 20}
    }
}
