import QtQuick 1.1
import Components 1.0
import "js/Stack.js" as Stack

Page {
    id: profilePage
    source: 'images/profiles.jpg'
    property string profile

    ToolBar {
        id: toolbar
        fontFamily: semiBoldFont.name
        fontSize: 17
        onHomeClicked: Stack.backToHome()
    }


    ButtonBack {
        id: backButton
        onClicked: Stack.popPage()
        anchors.topMargin: parent.height / 100 * 5
        anchors.top: toolbar.bottom
        anchors.leftMargin: parent.width / 100 * 5
        anchors.left: parent.left
    }

    Pannable {
        id: pannable
        anchors.left: backButton.right
        anchors.leftMargin: parent.width / 100 * 1
        anchors.top: backButton.top
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.height / 100 * 5
        anchors.right: parent.right
        anchors.rightMargin: parent.width / 100 * 3


        Text {
            id: headerProfileRect
            anchors.top: parent.top
            anchors.left: profileRect.left
            text: qsTr("profile")
            font.capitalization: Font.AllUppercase
            font.bold: true
            font.pixelSize: 16
        }

        Rectangle {
            id: profileRect
            width: 200
            height: 100
            color: "grey"
            anchors.right: parent.right
            anchors.top: headerProfileRect.bottom

            Image {
                id: imageProfile
                width: 100
                height: parent.height
                source: "images/home/card_1.png"
            }

            Text {
                anchors.left: imageProfile.right
                anchors.right: parent.right
                horizontalAlignment: Text.AlignHCenter
                anchors.top: parent.top
                anchors.topMargin: 10
                font.pixelSize: 16
                text: profilePage.profile
            }
        }
    }

}
