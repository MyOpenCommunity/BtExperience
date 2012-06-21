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

        property variant actualFavorite: undefined
        property variant movingObject: undefined

        function selectObj(favorite) {
            unselectObj()
            favorite.z = bgPannable.z + 1
            bgPannable.visible = true
            privateProps.actualFavorite = favorite
        }

        function unselectObj() {
            bgPannable.visible = false
            if (profilePage.state !== "")
                profilePage.state = ""
            if (privateProps.actualFavorite) {
                privateProps.actualFavorite.z = 0
                privateProps.actualFavorite.state = ""
            }
            // TODO gestire il focus?
            privateProps.actualFavorite = undefined
        }

        function updateProfileView() {
            clearProfileObjects()
            createProfileObjects()
        }

        function moveBegin(favorite) {
            unselectObj()
            movingObject = favorite
            moveGrid.state = "shown"
        }

        function moveEnd() {
            moveGrid.state = ""
            movingObject = undefined
        }

        function clearProfileObjects() {
            var len = Script.container.length
            for (var i = 0; i < len; ++i)
                Script.container.pop().destroy()
        }

        function createProfileObjects() {
            for (var i = 0; i < mediaLinks.count; ++i) {
                var obj = mediaLinks.getObject(i);
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

                // x and y are absolute coordinates
                var res = pannableChild.mapFromItem(null, obj.position.x, obj.position.y)
                var instance = component.createObject(pannableChild, {'x': res.x, 'y': res.y, 'text': text, 'address': address})

                instance.requestEdit.connect(showEditBox)
                instance.selected.connect(selectObj)
                instance.requestMove.connect(moveBegin)
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
        CameraLink { }
    }

    Component {
        id: rssItemComponent
        RssItem { }
    }

    Component {
        id: popup
        FavoriteEditPopup { }
    }

    Component {
        id: popupAddNote
        EditNote {
            onOkClicked: {
                userNotes.append(myHomeModels.createNote(profile.uii, text))
                privateProps.unselectObj()
            }
            onCancelClicked: privateProps.unselectObj()
        }
    }

    Component {
        id: popupEditNote
        EditNote {
            onOkClicked: {
                // we must set text directly on obj otherwise mods are lost
                privateProps.actualFavorite.obj.text = text
                privateProps.unselectObj()
            }
            onCancelClicked: privateProps.unselectObj()
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
                // a line from the paginator background remains visible if I
                // delete all notes; the following line avoids to see it in
                // such a case
                opacity: model.count === 0 ? 0 : 1

                delegate: Rectangle {
                    id: delegate

                    property variant obj: userNotes.getObject(index)
                    property string text: delegate.obj === undefined ? "" : delegate.obj.text

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
                        text: delegate.text
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
                        onEditClicked: {
                            installPopup(popupEditNote)
                            popupLoader.item.text = delegate.text
                        }
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
                onCurrentPageChanged: privateProps.unselectObj()
            }

            Grid {
                id: moveGrid
                anchors {
                    left: parent.left
                    right: rightArea.left
                    top: parent.top
                    bottom: parent.bottom
                }

                columns: 4
                rows: 4
                opacity: 0

                Repeater {
                    model: moveGrid.columns * moveGrid.rows

                    delegate: Rectangle {
                        id: rectDelegate
                        color: "transparent"
                        width: moveGrid.width / moveGrid.columns
                        height: moveGrid.height / moveGrid.rows
                        border {
                            width: 1
                            color: "red"
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                // map the coordinates to the quicklink's parent
                                var absPos = parent.mapToItem(null, x, y)
                                var itemPos = pannableChild.mapFromItem(null, absPos.x, absPos.y)
                                privateProps.movingObject.x = itemPos.x
                                privateProps.movingObject.y = itemPos.y
                                privateProps.moveEnd()
                            }
                        }
                    }
                }

                Behavior on opacity {
                    NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                }

                states: [
                    State {
                        name: "shown"
                        PropertyChanges {
                            target: moveGrid
                            opacity: 1
                        }
                    }
                ]
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
