import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Text 1.0
import "js/Stack.js" as Stack
import "js/array.js" as Script
import "js/navigation.js" as Navigation


Page {
    id: profilePage

    property variant profile

    source: profilePage.profile.image
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
        onModelReset: {
            // TODO: maybe we can optimize performance by setting opacity to 0
            // for items that we don't want to show, thus avoiding a whole
            // createObject()/destroy() cycle each time
            // Anyway, this needs a more complex management and performance gains
            // must be measurable.
            privateProps.updateProfileView()
        }
    }

    QtObject {
        id: privateProps

        property Item actualFavorite: null
        // the following properties are used to compute margins for the moving area
        // we have to be sure that elements moved on the bottom and right part of
        // the area don't overlap the area margins
        property int maxItemWidth: 0
        property int maxItemHeight: 0

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
            privateProps.actualFavorite = null
        }

        function updateProfileView() {
            clearProfileObjects()
            createProfileObjects()
        }

        function moveBegin(favorite) {
            unselectObj()
            privateProps.actualFavorite = favorite
            bgMoveArea.state = "shown"
        }

        function moveEnd() {
            bgMoveArea.state = ""
            privateProps.actualFavorite = null
        }

        function clearProfileObjects() {
            var len = Script.container.length
            for (var i = 0; i < len; ++i)
                Script.container.pop().destroy()
        }

        function deleteFavorite(favorite) {
            unselectObj()
            var index = Script.container.indexOf(favorite)
            var deletingObject = Script.container.splice(index, 1)[0]
            mediaLinks.remove(favorite.itemObject)
            deletingObject.destroy()
        }

        function createProfileObjects() {
            // here we compute the ref point for QuickLinks; essentially, this is the center of the moving
            // area where QuickLinks will be positioned
            var refX = bgMoveArea.mapToItem(null, bgMoveArea.x, bgMoveArea.y).x + 0.5 * bgMoveArea.width
            if (refX === 0) // no init done, do not lose time
                return
            var refY = bgMoveArea.mapToItem(null, bgMoveArea.x, bgMoveArea.y).y + 0.5 * bgMoveArea.height

            for (var i = 0; i < mediaLinks.count; ++i) {
                var obj = mediaLinks.getObject(i);
                var text = obj.name

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

                // new quicklink do not have a position yet; they will be positioned after all
                // other items
                if (obj.position.x < 0 && obj.position.y < 0)
                    continue

                var instance = component.createObject(pannableChild, {'x': res.x, 'y': res.y, "refX": refX, "refY": refY, "itemObject": obj, "profile": profilePage.profile})

                // area margins are set to maximum quicklink size / 2; this info is used to draw
                // an area in which QuickLinks don't overlap the area itself
                privateProps.maxItemWidth = Math.max(privateProps.maxItemWidth, instance.width)
                privateProps.maxItemHeight = Math.max(privateProps.maxItemHeight, instance.height)

                instance.requestEdit.connect(showEditBox)
                instance.selected.connect(selectObj)
                instance.requestMove.connect(moveBegin)
                instance.requestDelete.connect(deleteFavorite)

                Script.container.push(instance)
            }

            // we need absolute coordinates to position items without a position
            var absArea = bgMoveArea.mapToItem(null, bgMoveArea.x, bgMoveArea.y)

            for (var j = 0; j < mediaLinks.count; ++j) {
                var link = mediaLinks.getObject(j)

                // skip already done
                if (link.position.x >= 0 || link.position.y >= 0)
                    continue

                // random position inside the move area; we have to remove the margins around the area and
                // the offset wrt the item center (so we have 1.5)
                var deltaX = Math.random() * (bgMoveArea.width - 1.5 * privateProps.maxItemWidth)
                var deltaY = Math.random() * (bgMoveArea.height - 1.5 * privateProps.maxItemHeight)
                res = pannableChild.mapFromItem(null, absArea.x + deltaX, absArea.y + deltaY)

                instance = component.createObject(pannableChild, {'x': res.x, 'y': res.y, "refX": refX, "refY": refY, "itemObject": link})
                link.position = Qt.point(absArea.x + deltaX, absArea.y + deltaY)

                // area margins are set to maximum quicklink size / 2; this info is used to draw
                // an area in which QuickLinks don't overlap the area itself
                privateProps.maxItemWidth = Math.max(privateProps.maxItemWidth, instance.width)
                privateProps.maxItemHeight = Math.max(privateProps.maxItemHeight, instance.height)

                instance.requestEdit.connect(showEditBox)
                instance.selected.connect(selectObj)
                instance.requestMove.connect(moveBegin)
                instance.requestDelete.connect(deleteFavorite)

                Script.container.push(instance)
            }
        }

        function showEditBox(favorite) {
            installPopup(popup)
            popupLoader.item.favoriteItem = favorite.itemObject
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

                Image {
                    id: profileRect
                    source: "images/profile-settings/bg_settings_profile.svg"
                    width: 212
                    height: 100

                    Image {
                        id: imageProfile
                        width: parent.width / 100 * 38
                        height: parent.height / 100 * 80
                        anchors.top: parent.top
                        anchors.topMargin: parent.height / 100 * 8
                        source: profilePage.profile.cardImageCached
                        fillMode: Image.PreserveAspectFit
                    }

                    Image {
                        id: imageProfileSettings
                        anchors.right: parent.right
                        anchors.rightMargin: parent.width / 100 * 6
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: parent.height / 100 * 8
                        source: "images/profile-settings/icon_settings_profile.svg"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: Stack.goToPage("Settings.qml", {navigationTarget: Navigation.PROFILE, navigationData: profilePage.profile})
                    }

                    UbuntuLightText {
                        anchors {
                            left: imageProfile.right
                            right: parent.right
                            top: parent.top
                            topMargin: 10
                        }
                        horizontalAlignment: Text.AlignLeft
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
                    BeepingMouseArea {
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
                            popupLoader.item.setInitialText(delegate.text)
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

            MoveArea {
                id: bgMoveArea

                function moveTo(absX, absY) {
                    var itemPos = pannableChild.mapFromItem(null, absX, absY)
                    privateProps.actualFavorite.x = itemPos.x
                    privateProps.actualFavorite.y = itemPos.y
                    privateProps.actualFavorite.itemObject.position = Qt.point(absX, absY)
                }
                maxItemHeight: privateProps.maxItemHeight
                maxItemWidth: privateProps.maxItemWidth

                z: bgPannable.z + 2 // must be on top of quicklinks
                anchors {
                    left: parent.left
                    right: rightArea.left
                    rightMargin: 10
                    top: parent.top
                    bottom: parent.bottom
                }

                onMoveEnd: privateProps.moveEnd()

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

    // we need update instead of create because model is reset a couple of times
    // before Component completes loading
    Component.onCompleted: privateProps.updateProfileView()
}
