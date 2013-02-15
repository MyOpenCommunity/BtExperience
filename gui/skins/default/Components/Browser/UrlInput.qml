import QtQuick 1.0
import Components 1.0
import Components.Text 1.0

Item {
    id: container

    property alias url: urlText.text
    property variant view
    property bool ssl

    signal urlEntered(string url)
    signal urlChanged
    signal favoritesClicked

    height: parent.height

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        x: 8
        height: 4
        width: (parent.width - 16) * view.progress
        color: "#63b1ed"
        opacity: view.progress === 1.0 ? 0.0 : 1.0
    }

    UbuntuMediumTextInput {
        id: urlText
        horizontalAlignment: TextEdit.AlignLeft
        font.pixelSize: 14
        selectedTextColor: "white"
        selectionColor: "royalblue"
        onFocusChanged: {
            if (focus)
                focusTimer.start()
        }

        // We get a focus event then a mouse click, so we immediately lose the
        // selection. Workaround suggested in:
        // http://comments.gmane.org/gmane.comp.lib.qt.qml/2650
        Timer {
            id: focusTimer
            interval: 1
            onTriggered: urlText.selectAll()
        }

        onTextChanged: container.urlChanged()

        Keys.onEscapePressed: {
            urlText.text = view.url
            view.focus = true
        }

        Keys.onEnterPressed: {
            container.urlEntered(urlText.text)
            view.focus = true
        }

        Keys.onReturnPressed: {
            container.urlEntered(urlText.text)
            view.focus = true
        }

        anchors {
            left: sslIcon.visible ? sslIcon.right : favoritesIcon.right
            right: parent.right
            rightMargin: 18
            verticalCenter: parent.verticalCenter
        }
    }

    Item {
        id: favoritesIcon

        width: 30
        height: 36

        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
        }

        SvgImage {
            source: "../../images/common/ico_favorites.svg"
            anchors.centerIn: parent
            width: 18
            height: 18
        }

        MouseArea {
            anchors.fill: parent
            onClicked: favoritesClicked()
        }
    }

    Item {
        id: sslIcon

        width: 30
        height: 36
        visible: ssl

        anchors {
            left: favoritesIcon.right
            verticalCenter: parent.verticalCenter
        }

        SvgImage {
            source: "../../images/common/ico_lock.svg"
            anchors.centerIn: parent
        }
    }
}
