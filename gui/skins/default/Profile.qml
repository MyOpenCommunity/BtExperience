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
            width: 212
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

        Text {
            id: headerNote
            anchors.top: profileRect.bottom
            anchors.topMargin: 30
            anchors.left: profileRect.left
            text: qsTr("note")
            font.capitalization: Font.AllUppercase
            font.bold: true
            font.pixelSize: 16
        }

        SvgImage {
            id: addNote
            source: "images/common/menu_column_item_bg.svg";
            anchors.right: parent.right
            anchors.top: headerNote.bottom

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 5
                anchors.top: parent.top
                anchors.topMargin: 5
                font.pixelSize: 16
                text: qsTr("aggiungi nota")
            }

            Image {
                source: "images/common/piu.png"
                anchors.right: parent.right
                anchors.top: parent.top
            }
        }

        PaginatorList {
            anchors.top: addNote.bottom
            anchors.topMargin: 10
            anchors.left: addNote.left

            id: paginator
            width: addNote.width
            elementsOnPage: 4
            listHeight: model.count > elementsOnPage ? elementsOnPage * 50 : model.count * 50

            delegate: SvgImage {
                source: "images/common/menu_column_item_bg.svg";

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 5
                    anchors.right: parent.right
                    anchors.rightMargin: 5
                    anchors.top: parent.top
                    anchors.topMargin: 5
                    font.pixelSize: 16
                    text: model.text
                }
            }

            model: ListModel {
                ListElement {
                    text: "Prendere il pane"
                }
                ListElement {
                    text: "23 Giugno dottore"
                }
                ListElement {
                    text: "1 Luglio compleanno di Luca"
                }
                ListElement {
                    text: "pagare spese condominiali"
                }

            }
        }
        FavoriteItem {
            x: 200
            y: 50
            onRequestEdit: profilePage.showEditBox(favorite)
        }

        FavoriteItem {
            x: 300
            y: 250
            onRequestEdit: profilePage.showEditBox(favorite)
        }
    }

    function showEditBox(favorite) {
        installPopup(popup)
        popupLoader.item.favoriteItem = favorite
    }

    Component {
        id: popup
        FavoriteEditPopup { }
    }
}
