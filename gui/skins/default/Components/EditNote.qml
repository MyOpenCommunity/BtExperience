import QtQuick 1.1
import Components.Text 1.0


SvgImage {
    id: bg

    signal closePopup
    signal okClicked
    signal cancelClicked

    property alias text: edit.text
    property alias title: titleLabel.text

    function setInitialText(t) {
        text = t
    }

    source: "../images/scenarios/bg_testo.svg"

    UbuntuLightText {
        id: titleLabel
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
            interactive: false
            clip: true

            function ensureVisible(r) {
                if (contentX >= r.x)
                    contentX = r.x;
                else if (contentX + width <= r.x + r.width)
                    contentX = r.x + r.width-width;
                if (contentY >= r.y)
                    contentY = r.y;
                else if (contentY + height <= r.y + r.height)
                    contentY = r.y + r.height - height;
            }

            UbuntuLightTextEdit {
                id: edit
                property bool initialized: false
                text: ""
                width: flick.width
                height: flick.height
                focus: true
                wrapMode: TextEdit.Wrap
                onCursorRectangleChanged: flick.ensureVisible(cursorRectangle)
                onTextChanged: {
                    if (initialized)
                        return
                    edit.cursorPosition = text.length
                    edit.initialized = true
                }
                containerWidget: bg
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

        ButtonThreeStates {
            defaultImage: "../images/common/btn_99x35.svg"
            pressedImage: "../images/common/btn_99x35_P.svg"
            selectedImage: "../images/common/btn_99x35_S.svg"
            shadowImage: "../images/common/btn_shadow_99x35.svg"
            text: qsTr("OK")
            font.pixelSize: 14
            onClicked: {
                bg.okClicked()
                bg.closePopup()
            }
        }

        ButtonThreeStates {
            defaultImage: "../images/common/btn_99x35.svg"
            pressedImage: "../images/common/btn_99x35_P.svg"
            selectedImage: "../images/common/btn_99x35_S.svg"
            shadowImage: "../images/common/btn_shadow_99x35.svg"
            text: qsTr("CANCEL")
            font.pixelSize: 14
            onClicked: {
                bg.cancelClicked()
                bg.closePopup()
            }
        }
    }

    Component.onCompleted: edit.forceActiveFocus()
}
