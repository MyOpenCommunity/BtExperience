import QtQuick 1.1
import "js/Stack.js" as Stack

Item {
    id: bgQuick

    property alias imageSource: icon.source
    property alias text: label.text
    property string address: "www.corriere.it"
    property string page: "Browser.qml"
    property string bgImage: "images/profiles/web.png"
    property bool editable: true

    property int additionalWidth: 10

    signal selected(variant favorite)
    signal unselected(variant favorite)
    signal requestEdit(variant favorite)
    signal clicked()
    signal editCompleted()

    width: column.width + 10
    height: column.height + 10

    QtObject {
        id: privateProps
        property string currentText: ""
    }

    Column {
        id: column

        spacing: 10
        Rectangle {
            id: highlight
            width: icon.width + additionalWidth
            height: icon.height + additionalWidth
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
                source: bgImage
            }
        }

        TextInput {
            id: label

            color: "white"
            anchors.horizontalCenter: parent.horizontalCenter
            text: title
            horizontalAlignment: Text.AlignHCenter
            width: icon.width

            activeFocusOnPress: false
            onActiveFocusChanged: {
                if (!activeFocus) { // edit done
                    if (label.text !== privateProps.currentText)
                        bgQuick.editCompleted()
                }
            }
        }
    }

    Column {
        id: editColumn

        opacity: 0
        anchors.left: column.right
        anchors.leftMargin: 1

        Rectangle {
            width: 48
            height: 48
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
            width: 48
            height: 48
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
            Image {
                source: "images/icon_pencil.png"
                anchors.fill: parent
                anchors.margins: 10
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    console.log("Clicked on edit icon")
                    bgQuick.requestEdit(bgQuick)
                }
            }
        }

        Rectangle {
            width: 48
            height: 48
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
            Image {
                source: "images/icon_move.png"
                anchors.fill: parent
                anchors.margins: 10
            }
        }

        Rectangle {
            width: 48
            height: 48
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
        onPressAndHold: {
            privateProps.currentText = label.text
            if (bgQuick.editable) {
                label.forceActiveFocus()
                label.openSoftwareInputPanel()
            }
            parent.state = "selected"
        }
        onClicked: {
            if (page !== "")
                Stack.openPage(page, {'urlString': address})
            bgQuick.clicked()
        }
        onPressed: bgQuick.unselected(bgQuick)
    }

    states: [
        State {
            name: ""
            StateChangeScript {
                script: bgQuick.unselected(bgQuick)
            }
        },
        State {
            name: "selected"
            PropertyChanges {
                target: column
                anchors.margins: editable ? 0 : column.margins
            }
            PropertyChanges {
                target: bgQuick
                additionalWidth: editable ? 20 : bgQuick.additionalWidth
            }
            PropertyChanges {
                target: editColumn
                opacity: editable ? 1 : editColumn.opacity
            }
            PropertyChanges {
                target: highlight
                radius: editable ? 0 : highlight.radius
            }
            StateChangeScript {
                // execute selected script when not editable?
                script: editable ? bgQuick.selected(bgQuick) : ""
            }
        }
    ]
}
