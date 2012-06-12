import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Text 1.0
import "js/Stack.js" as Stack


Page {
    id: profilePage
    source: 'images/profiles.jpg'
    property variant profile
    text: profile.description
    showSystemsButton: false

    Pannable {
        id: pannable
        anchors.left: navigationBar.right
        anchors.leftMargin: parent.width / 100 * 1
        anchors.top: navigationBar.top
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

            ProfileView {
                model: mediaLinks
                container: pannableChild
                anchors.fill: parent
            }

            Column {
                id: rightArea
                anchors.top: parent.top
                anchors.right: parent.right

                UbuntuMediumText {
                    id: headerProfileRect
                    text: qsTr("profile")
                    font.capitalization: Font.AllUppercase
                    font.pixelSize: 16
                }

                Rectangle {
                    id: profileRect
                    width: 212
                    height: 100
                    color: "grey"

                    Image {
                        id: imageProfile
                        width: 100
                        height: parent.height
                        source: profilePage.profile.image
                        fillMode: Image.PreserveAspectFit
                    }

                    UbuntuLightText {
                        anchors.left: imageProfile.right
                        anchors.right: parent.right
                        horizontalAlignment: Text.AlignHCenter
                        anchors.top: parent.top
                        anchors.topMargin: 10
                        font.pixelSize: 16
                        text: profilePage.profile.description
                    }
                }

                Item {
                    height: 30
                    width: parent.width
                }

                UbuntuMediumText {
                    id: headerNote
                    text: qsTr("note")
                    font.capitalization: Font.AllUppercase
                    font.pixelSize: 16
                }

                SvgImage {
                    id: addNote
                    source: "images/common/menu_column_item_bg.svg";
                    anchors.right: parent.right

                    UbuntuLightText {
                        anchors.left: parent.left
                        anchors.leftMargin: 5
                        anchors.top: parent.top
                        anchors.topMargin: 5
                        font.pixelSize: 14
                        text: qsTr("Add note")
                    }

                    SvgImage {
                        source: "images/common/symbol_plus.svg"
                        anchors {
                            right: parent.right
                            rightMargin: parent.width / 100 * 2
                            top: parent.top
                            topMargin:  parent.height / 100 * 10
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: pannableChild.addNote()
                    }
                }

                Item {
                    height: 10
                    width: parent.width
                }

                PaginatorList {

                    id: paginator
                    width: addNote.width
                    elementsOnPage: 3

                    delegate: Rectangle {
                        id: delegate
                        color: index % 2 !== 0 ? "light gray" : "gray"
                        // TODO: this should probably be a background image.
                        // It's a bad idea to have delegates of different sizes
                        // (think empty space at bottom, think moving paginator
                        // at bottom and so on)
                        // Leave size hardcoded for now.
                        width: 212
                        height: 60
                        property variant obj: userNotes.getObject(index)

                        UbuntuLightText {
                            anchors.left: parent.left
                            anchors.leftMargin: delegate.width / 100 * 2
                            anchors.right: crossImage.left
                            anchors.rightMargin: delegate.width / 100 * 2
                            anchors.top: parent.top
                            anchors.topMargin: delegate.height / 100 * 9
                            font.pixelSize: 13
                            wrapMode: Text.Wrap
                            text: delegate.obj.text
                            elide: Text.ElideRight
                            maximumLineCount: 3
                        }
                        SvgImage {
                            id: crossImage
                            anchors.right: parent.right
                            anchors.rightMargin: delegate.width / 100 * 2
                            anchors.top: parent.top
                            anchors.topMargin: delegate.height / 100 * 9
                            source: "images/common/icon_delete.svg"
                            MouseArea {
                                anchors.fill: parent
                                onClicked: userNotes.remove(index)
                            }
                        }
                    }
                    model: userNotes
                }

                MediaModel {
                    id: userNotes
                    source: myHomeModels.notes
                    containers: [profile.uii]
                    range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
                }

            }

            MediaModel {
                id: mediaLinks
                source: myHomeModels.mediaLinks
                containers: [profile.uii]
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

                            UbuntuLightText {
                                anchors.centerIn: parent
                                text: qsTr("ok")
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    userNotes.append(myHomeModels.createNote(profile.uii, textEdit.text))
                                    closePopup()
                                }
                            }
                        }

                        Image {
                            id: buttonCancel
                            source: "images/common/btn_OKAnnulla.png"

                            UbuntuLightText {
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
