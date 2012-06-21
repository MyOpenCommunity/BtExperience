import QtQuick 1.1
import Components.Text 1.0


Rectangle {
    id: bg

    signal closePopup
    signal okClicked
    signal cancelClicked

    property alias text: edit.text

    width: 300
    height: 200
    color: "light gray"

    UbuntuLightText {
        text: qsTr("Note")
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.top: parent.top
    }

    Rectangle {
        color: "white"
        anchors {
            top: parent.top
            topMargin: 20
            bottom: buttonsRow.top
            bottomMargin: 10
            left: parent.left
            leftMargin: 10
            right: parent.right
            rightMargin: 10
        }

        Flickable {
            id: flick

            anchors.fill: parent
            contentWidth: edit.paintedWidth
            contentHeight: edit.paintedHeight
            clip: true

            function ensureVisible(r)
            {
                if (contentX >= r.x)
                    contentX = r.x;
                else if (contentX+width <= r.x+r.width)
                    contentX = r.x+r.width-width;
                if (contentY >= r.y)
                    contentY = r.y;
                else if (contentY+height <= r.y+r.height)
                    contentY = r.y+r.height-height;
            }

            UbuntuLightTextEdit {
                id: edit
                text: ""
                width: flick.width
                height: flick.height
                focus: true
                wrapMode: TextEdit.Wrap
                onCursorRectangleChanged: flick.ensureVisible(cursorRectangle)
                cursorPosition: text.length
            }
        }

    }

    Row {
        id: buttonsRow

        spacing: 0
        anchors {
            bottom: parent.bottom
            bottomMargin: 10
            right: parent.right
            rightMargin: 10
        }

        Image {
            id: buttonOk
            source: "../images/common/btn_OKAnnulla.png"

            UbuntuLightText {
                anchors.centerIn: parent
                text: qsTr("ok")
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    bg.okClicked()
                    bg.closePopup()
                }
            }
        }

        Image {
            id: buttonCancel
            source: "../images/common/btn_OKAnnulla.png"

            UbuntuLightText {
                anchors.centerIn: parent
                text: qsTr("cancel")
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    bg.cancelClicked()
                    bg.closePopup()
                }
            }
        }
    }

    Component.onCompleted: edit.forceActiveFocus()
}
