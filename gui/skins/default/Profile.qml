import QtQuick 1.1
import Components 1.0
import "js/Stack.js" as Stack

Page {
    id: profilePage
    source: 'images/profiles.jpg'
    property string profile
    property url sourceImage

    ToolBar {
        id: toolbar
        fontFamily: semiBoldFont.name
        fontSize: 17
        onHomeClicked: Stack.backToHome()
    }


    NavigationBar {
        id: navbar
        systemsButton: false
        anchors.topMargin: parent.height / 100 * 5
        anchors.top: toolbar.bottom
        anchors.leftMargin: 2
        anchors.left: parent.left

        onBackClicked: Stack.popPage()
    }

    Pannable {
        id: pannable
        anchors.left: navbar.right
        anchors.leftMargin: parent.width / 100 * 1
        anchors.top: navbar.top
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.height / 100 * 5
        anchors.right: parent.right
        anchors.rightMargin: parent.width / 100 * 3

        Item {
            id: pannableChild
            x: 0
            y: parent.childOffset
            width: parent.width
            height: parent.height

            Rectangle {
                id: bgPannable

                property variant actualFavorite: undefined

                visible: false
                color: "black"
                opacity: 0.5
                radius: 20
                anchors.fill: parent
                z: 1
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        bgPannable.visible = false
                        bgPannable.actualFavorite.z = 0
                        bgPannable.actualFavorite.state = ""
                        // TODO gestire il focus?
                        bgPannable.actualFavorite = undefined
                    }
                }
            }

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
                    source: profilePage.sourceImage
                    fillMode: Image.PreserveAspectFit
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
                    text: qsTr("Add Note")
                }

                Image {
                    source: "images/common/piu.png"
                    anchors.right: parent.right
                    anchors.top: parent.top
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: pannableChild.addNote()
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

                delegate: Rectangle {
                    color: index % 2 !== 0 ? "light gray" : "gray"
                    width: 212
                    height: 50
                    property variant obj: global.noteListModel.getObject(index)

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 5
                        anchors.right: parent.right
                        anchors.rightMargin: 5
                        anchors.top: parent.top
                        anchors.topMargin: 5
                        font.pixelSize: 16
                        wrapMode: Text.WordWrap
                        text: obj.text
                    }
                    Image {
                        anchors.right: parent.right
                        anchors.rightMargin: 5
                        anchors.top: parent.top
                        anchors.topMargin: 5
                        source: "images/profiles/icon_x.png"
                        width: 20
                        height: 20
                        MouseArea {
                            anchors.fill: parent
                            onClicked: global.noteListModel.remove(index)
                        }
                    }

                }

                model: global.noteListModel
            }

            FavoriteItem {
                x: 200
                y: 50
                onRequestEdit: pannableChild.showEditBox(favorite)
                onSelected: pannableChild.bringOver(favorite)
            }

            FavoriteItem {
                x: 300
                y: 250
                onRequestEdit: pannableChild.showEditBox(favorite)
                onSelected: pannableChild.bringOver(favorite)
            }

            RssItem {
                x: 400
                y: 100
                onRequestEdit: pannableChild.showEditBox(favorite)
                onSelected: pannableChild.bringOver(favorite)
            }

            CameraLink {
                x: 500
                y: 220
                onRequestEdit: pannableChild.showEditBox(favorite)
                onSelected: pannableChild.bringOver(favorite)
            }

            function bringOver(favorite) {
                favorite.z = bgPannable.z + 1
                bgPannable.visible = true
                bgPannable.actualFavorite = favorite
            }

            function showEditBox(favorite) {
                installPopup(popup)
                popupLoader.item.favoriteItem = favorite
            }

            Component {
                id: popup
                FavoriteEditPopup { }
            }


            function addNote() {
                installPopup(popupAddNote)
            }

            Component {
                id: popupAddNote
                Rectangle {

                    signal closePopup
                    width: 300
                    height: 200
                    color: "light gray"
                    Text {
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
                        TextEdit {
                            id: textEdit
                            anchors.fill: parent
                            text: ""
                        }
                    }
                    Row {
                        id: buttonsRow
                        spacing: 0
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 10
                        anchors.right: parent.right
                        anchors.rightMargin: 10

                        Image {
                            id: buttonOk
                            source: "images/common/btn_OKAnnulla.png"

                            Text {
                                anchors.centerIn: parent
                                text: qsTr("ok")
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    global.noteListModel.append(textEdit.text)
                                    closePopup()
                                }
                            }
                        }

                        Image {
                            id: buttonCancel
                            source: "images/common/btn_OKAnnulla.png"

                            Text {
                                anchors.centerIn: parent
                                text: qsTr("cancel")
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    closePopup()
                                }
                            }
                        }
                    }
                    Component.onCompleted: textEdit.forceActiveFocus()
                }
            }
        }
    }
}
