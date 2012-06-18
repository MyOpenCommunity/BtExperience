import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Text 1.0
import "js/Stack.js" as Stack
import "js/array.js" as Script


Page {
    id: profilePage

    property variant profile

    source: 'images/profiles.jpg'
    text: profile.description
    showSystemsButton: false

    MediaModel {
        id: userNotes
        source: myHomeModels.notes
        containers: [profile.uii]
        range: paginator.computePageRange(paginator.currentPage, paginator.elementsOnPage)
    }

    MediaModel {
        id: mediaLinks
        source: myHomeModels.mediaLinks
        containers: [profile.uii]
    }

    QtObject {
        id: privateProps

        function selectObj(object) {
            unselectObj()
            object.z = bgPannable.z + 1
            bgPannable.visible = true
            bgPannable.actualFavorite = object
        }

        function unselectObj() {
            if (profilePage.state !== "")
                profilePage.state = ""
            if (bgPannable.actualFavorite === undefined)
                return
            bgPannable.visible = false
            bgPannable.actualFavorite.z = 0
            bgPannable.actualFavorite.state = ""
            // TODO gestire il focus?
            bgPannable.actualFavorite = undefined
        }

        function updateProfileView() {
            clearProfileObjects()
            createProfileObjects()
        }

        function clearProfileObjects() {
            var len = Script.container.length
            for (var i = 0; i < len; ++i)
                Script.container.pop().destroy()
        }

        function createProfileObjects() {
            for (var i = 0; i < mediaLinks.count; ++i) {
                var obj = mediaLinks.getObject(i);
                var y = obj.position.y
                var x = obj.position.x
                var text = obj.name
                var address = obj.address

                var component;
                switch (obj.type) {
                case MediaLink.Web:
                    component = favouriteItemComponent
                    break
                case MediaLink.Rss:
                    component = rssItemComponent
                    break
                case MediaLink.Camera:
                    component = cameraItemComponent
                    break
                }

                var instance = component.createObject(pannableChild, {'x': x, 'y': y, 'text': text, 'address': address})

                instance.requestEdit.connect(function (instance) {
                                                 showEditBox(instance)
                                             })
                instance.selected.connect(function (instance) {
                                              selectObj(instance)
                                          })
                Script.container.push(instance)
            }
        }

        function showEditBox(favorite) {
            installPopup(popup)
            popupLoader.item.favoriteItem = favorite
        }

        function addNote() {
            installPopup(popupAddNote)
        }
    }

    Component {
        id: favouriteItemComponent
        FavoriteItem { }
    }

    Component {
        id: cameraItemComponent
        RssItem { }
    }

    Component {
        id: rssItemComponent
        CameraLink { }
    }

    Component {
        id: popup
        FavoriteEditPopup { }
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
                        onClicked: closePopup()
                    }
                }
            }
            Component.onCompleted: textEdit.forceActiveFocus()
        }
    }

    Pannable {
        id: pannable

        anchors {
            left: navigationBar.right
            leftMargin: parent.width / 100 * 1
            top: navigationBar.top
            bottom: parent.bottom
            bottomMargin: parent.height / 100 * 5
            right: parent.right
            rightMargin: parent.width / 100 * 3
        }

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
                    onClicked: privateProps.unselectObj()
                }
            }

            Item {
                id: profileView

                property variant model: mediaLinks

                anchors.fill: parent

                Component.onCompleted:privateProps.createProfileObjects()

                Connections {
                    target: profileView.model
                    onModelReset: {
                        // TODO: maybe we can optimize performance by setting opacity to 0
                        // for items that we don't want to show, thus avoiding a whole
                        // createObject()/destroy() cycle each time
                        // Anyway, this needs a more complex management and performance gains
                        // must be measurable.
                        privateProps.updateProfileView()
                    }
                }
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
                        anchors {
                            left: imageProfile.right
                            right: parent.right
                            top: parent.top
                            topMargin: 10
                        }
                        horizontalAlignment: Text.AlignHCenter
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
                        anchors {
                            left: parent.left
                            leftMargin: 5
                            top: parent.top
                            topMargin: 5
                        }
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
                        onClicked: privateProps.addNote()
                    }
                }
            }

            PaginatorList {
                id: paginator

                anchors {
                    top: rightArea.bottom
                    topMargin: 10
                    right: rightArea.right
                }

                width: addNote.width
                elementsOnPage: 3

                delegate: Rectangle {
                    id: delegate

                    property variant obj: userNotes.getObject(index)

                    color: index % 2 !== 0 ? "light gray" : "gray"
                    // TODO: this should probably be a background image.
                    // It's a bad idea to have delegates of different sizes
                    // (think empty space at bottom, think moving paginator
                    // at bottom and so on)
                    // Leave size hardcoded for now.
                    width: 212
                    height: 60

                    UbuntuLightText {
                        anchors {
                            left: parent.left
                            leftMargin: delegate.width / 100 * 2
                            right: parent.right
                            rightMargin: delegate.width / 100 * 2
                            top: parent.top
                            topMargin: delegate.height / 100 * 9
                        }
                        font.pixelSize: 13
                        wrapMode: Text.Wrap
                        text: delegate.obj === undefined ? "" : delegate.obj.text
                        elide: Text.ElideRight
                        maximumLineCount: 3
                    }

                    MouseArea {
                        anchors.fill: parent
                        onPressAndHold: {
                            privateProps.selectObj(delegate)
                            profilePage.state = "selected"
                            delegate.state = "selected"
                        }
                    }

                    NoteActions {
                        id: menu
                        onEditClicked: console.log("edit note")
                        onDeleteClicked: {
                            privateProps.unselectObj()
                            userNotes.remove(index)
                        }
                        anchors {
                            bottom: parent.bottom
                            right: parent.left
                        }
                    }

                    states: [
                        State {
                            name: "selected"
                            PropertyChanges {
                                target: menu
                                state: "selected"
                            }
                        }
                    ]
                }
                model: userNotes
            }
        }
    }

    states: [
        State {
            name: "selected"
            PropertyChanges {
                target: paginator
                z: bgPannable.z + 1
            }
        }
    ]
}
