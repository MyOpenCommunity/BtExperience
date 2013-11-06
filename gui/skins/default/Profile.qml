/*
 * Copyright © 2011-2013 BTicino S.p.A.
 *
 * This file is part of BtExperience.
 *
 * BtExperience is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BtExperience is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BtExperience. If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 1.1
import BtObjects 1.0
import Components 1.0
import Components.Popup 1.0
import Components.Text 1.0
import "js/Stack.js" as Stack
import "js/array.js" as Script
import "js/navigation.js" as Navigation


/**
  \ingroup Core

  \brief The profile page

  The profile page showing profile quicklinks and notes. The user may navigate
  to her settings page to change her profile card image and/or background.
  In the settings she may add quicklinks to her profile page or restore the
  default background image.
  In this page the user may save and read notes.
  */
Page {
    id: profilePage

    /** the profile to show */
    property variant profile

    /**
      Called when settings button on navigation bar is clicked.
      Navigates to profile settings page.
      */
    function settingsButtonClicked() {
        Stack.goToPage("Settings.qml", {navigationTarget: Navigation.PROFILE, navigationData: profilePage.profile})
    }

    source: profile.image === "" ? homeProperties.homeBgImage : profile.image
    text: profile.description
    showSystemsButton: false
    showSettingsButton: true

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
        // Default values are useful when no item is already present.
        property int maxItemWidth: 130
        property int maxItemHeight: 120

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

        function getComponentFromType(type) {
            var component
            switch (type) {
            case MediaLink.Web:
                component = favouriteItemComponent
                break
            case MediaLink.Webcam:
                component = webcamItemComponent
                break
            case MediaLink.Rss:
                component = rssItemComponent
                break
            case MediaLink.RssMeteo:
                component = meteoItemComponent
                break
            case MediaLink.Camera:
                component = cameraItemComponent
                break
            case MediaLink.Scenario:
                component = scenarioItemComponent
                break
            case MediaLink.WebRadio:
                component = webRadioItemComponent
                break
            default:
                console.log("Unrecognized type: "+type)
            }
            return component
        }

        function createProfileObjects() {
            // here we compute the ref point for QuickLinks; essentially, this is the center of the moving
            // area where QuickLinks will be positioned
            var refX = bgMoveArea.mapToItem(null, bgMoveArea.x, bgMoveArea.y).x + 0.5 * bgMoveArea.width
            if (refX === 0) // no init done, do not lose time
                return
            var refY = bgMoveArea.mapToItem(null, bgMoveArea.x, bgMoveArea.y).y + 0.5 * bgMoveArea.height

            for (var q = 0; q < mediaLinks.count; ++q) {
                // gets object
                var obj = mediaLinks.getObject(q)
                // gets absolute coordinates from object, they may be unknown (-1, -1)
                var absX = obj.position.x
                var absY = obj.position.y
                // computes area coordinates from absolute ones
                var areaPt = bgMoveArea.absolute2area(Qt.point(absX, absY))
                if (absX < 0 && absY < 0) {
                    // if position is unknown, generates a random one
                    areaPt = bgMoveArea.randomPosition()
                }
                // we add objects to pannableChild, so computes pannableChild coordinates
                var pannableChildPt = pannableChild.mapFromItem(null, absX, absY)
                // gets component type
                var component = getComponentFromType(obj.type)
                // creates object in pannableChild coordinates and invisible because it may be outside move area
                var object = component.createObject(pannableChild, {'x': pannableChildPt.x, 'y': pannableChildPt.y, "refX": refX, "refY": refY, "itemObject": obj, "profile": profilePage.profile, "opacity": 0.01})
                // now we know object size: reposition object inside move area if needed
                areaPt.x = bgMoveArea.xInRect(areaPt.x, object.width)
                areaPt.y = bgMoveArea.yInRect(areaPt.y, object.height)
                // recomputes pannableChild coordinates and assigns it to object
                pannableChildPt = pannableChild.mapFromItem(bgMoveArea, areaPt.x, areaPt.y)
                // disables animations on position
                object.xBehavior.enabled = false
                object.yBehavior.enabled = false
                object.x = pannableChildPt.x
                object.y = pannableChildPt.y
                // computes absolute coordinates and saves them in object
                var absPt = bgMoveArea.area2absolute(areaPt)
                obj.position = Qt.point(absPt.x, absPt.y)
                // registers needed signals
                object.requestEdit.connect(showEditBox)
                object.selected.connect(selectObj)
                object.requestMove.connect(moveBegin)
                object.requestDelete.connect(deleteFavorite)
                // shows and stores the object
                object.opacity = 1.0
                // object is in the right position, enables position animations again
                object.xBehavior.enabled = true
                object.yBehavior.enabled = true
                Script.container.push(object)
            }
        }

        function showEditBox(favorite) {
            unselectObj()
            installPopup(popup, {favoriteItem: favorite.itemObject})
        }

        function addNote() {
            if (userNotes.count >= 10) {
                installPopup(errorFeedback, { text: qsTr("Max notes limit reached") })
                return
            }
            installPopup(popupAddNote)
        }
    }

    Component {
        id: errorFeedback
        FeedbackPopup {
            isOk: false
        }
    }

    Component {
        id: favouriteItemComponent
        FavoriteItem {
            onClicked: profilePage.processLaunched(global.browser)
        }
    }

    Component {
        id: webcamItemComponent
        WebcamLink { }
    }

    Component {
        id: webRadioItemComponent
        WebRadioLink { }
    }

    Component {
        id: cameraItemComponent
        CameraLink { }
    }

    Component {
        id: scenarioItemComponent
        ScenarioLink { pageObject: profilePage }
    }

    Component {
        id: rssItemComponent
        RssItem { }
    }

    Component {
        id: meteoItemComponent
        MeteoItem {}
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
            maxLength: 130
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
            maxLength: 130
        }
    }

    Pannable {
        id: pannable

        anchors {
            left: navigationBar.right
            leftMargin: parent.width / 100 * 1
            top: navigationBar.top
            bottom: parent.bottom
            bottomMargin: parent.height / 100 * 1.67
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

                BeepingMouseArea {
                    anchors.fill: parent
                    onClicked: privateProps.unselectObj()
                }
            }

            Column {
                id: rightArea

                anchors {
                    top: parent.top
                    right: parent.right
                }

                SvgImage {
                    id: profileRect
                    source: "images/profile-settings/bg_settings_profile.svg"

                    ButtonImageThreeStates {
                        anchors {
                            right: parent.right
                            rightMargin: parent.height / 100 * 10
                            bottom: parent.bottom
                            bottomMargin: parent.height / 100 * 10
                        }

                        defaultImageBg: "images/common/btn_66x35.svg"
                        pressedImageBg: "images/common/btn_66x35_P.svg"
                        defaultImage: "images/profile-settings/icon_settings_profile.svg"
                        pressedImage: "images/profile-settings/icon_settings_profile_P.svg"
                        shadowImage: "images/common/btn_shadow_66x35.svg"
                        onPressed: Stack.goToPage("Settings.qml", {navigationTarget: Navigation.PROFILE, navigationData: profilePage.profile})
                    }

                    Image {
                        id: imageProfile
                        width: parent.width / 100 * 38
                        height: parent.height / 100 * 80
                        anchors.top: parent.top
                        anchors.topMargin: parent.height / 100 * 8
                        source: profilePage.profile.cardImageCached
                        fillMode: Image.PreserveAspectFit
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
                        color: "white"
                        text: profilePage.profile.description
                        elide: Text.ElideRight
                    }
                }

                Item {
                    height: 8
                    width: parent.width
                }

                SvgImage {
                    id: addNote
                    source: "images/profile-settings/bg_pager_panel.svg"

                    ButtonTextImageThreeStates {
                        anchors.centerIn: parent
                        text: qsTr("Add note")

                        defaultImageBg: "images/common/btn_cercapersone.svg"
                        pressedImageBg: "images/common/btn_cercapersone_P.svg"

                        defaultImage: "images/common/ico_piu.svg"
                        pressedImage: "images/common/ico_piu_P.svg"
                        imageAnchors.rightMargin: parent.width / 100 * 5

                        shadowImage: "images/common/ombra_btn_cercapersone.svg"

                        onPressed: privateProps.addNote()
                    }
                }
            }

            Column {
                id: paginatorBackground

                anchors {
                    top: rightArea.bottom
                    left: rightArea.left
                }

                SvgImage {
                    source: "images/profile-settings/bg_note_panel.svg"
                }

                SvgImage {
                    source: "images/profile-settings/bg_pager_panel.svg"
                }
            }

            PaginatorOnBackground {
                id: paginator

                anchors {
                    top: paginatorBackground.top
                    bottom: paginatorBackground.bottom
                    left: paginatorBackground.left
                    right: paginatorBackground.right
                }
                bottomRowAnchors.bottomMargin: paginatorBackground.height / 100 * 3
                bottomRowAnchors.leftMargin: paginatorBackground.width / 100 * 9

                width: addNote.width
                elementsOnPage: 2

                delegate: Item {
                    id: delegate

                    property variant obj: userNotes.getObject(index)
                    property string text: delegate.obj === undefined ? "" : delegate.obj.text

                    width: bgDelegate.width + 14
                    height: bgDelegate.height + 8

                    SvgImage {
                        id: bgDelegate
                        source: "images/profile-settings/bg_note.svg"
                        anchors {
                            bottom: parent.bottom
                            horizontalCenter: parent.horizontalCenter
                        }
                    }

                    SvgImage {
                        id: closeButton

                        source: "images/profile-settings/icon_delete.svg"
                        anchors {
                            right: bgDelegate.right
                            rightMargin: delegate.width / 100 * 5
                            top: bgDelegate.top
                            topMargin: delegate.height / 100 * 5
                        }
                    }

                    BeepingMouseArea {
                        anchors.centerIn: closeButton
                        width: 15
                        height: 15
                        onClicked: userNotes.remove(index)
                        z: 1
                    }

                    UbuntuLightText {
                        anchors {
                            left: bgDelegate.left
                            leftMargin: delegate.width / 100 * 2
                            right: bgDelegate.right
                            rightMargin: delegate.width / 100 * 2
                            top: closeButton.bottom
                            topMargin: delegate.height / 100 * 5
                        }
                        color: "#323232"
                        font.pixelSize: 15
                        wrapMode: Text.Wrap
                        text: delegate.text
                        elide: Text.ElideRight
                        maximumLineCount: 6
                    }

                    BeepingMouseArea {
                        anchors.fill: parent
                        pressAndHoldEnabled: true
                        onHeld: {
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
                    // click refers to item center so computes offsets
                    var oX = privateProps.actualFavorite.width / 2
                    var oY = privateProps.actualFavorite.height / 2
                    // computes area coordinates from absolute ones taking offsets into consideration
                    var areaPt = bgMoveArea.absolute2area(Qt.point(absX - oX, absY - oY))
                    // repositions object inside move area if needed
                    areaPt.x = bgMoveArea.xInRect(areaPt.x, privateProps.actualFavorite.width)
                    areaPt.y = bgMoveArea.yInRect(areaPt.y, privateProps.actualFavorite.height)
                    // we move objects inside pannableChild, so computes pannableChild coordinates
                    var pannableChildPt = pannableChild.mapFromItem(bgMoveArea, areaPt.x, areaPt.y)
                    privateProps.actualFavorite.x = pannableChildPt.x
                    privateProps.actualFavorite.y = pannableChildPt.y
                    // computes absolute coordinates and saves them in object
                    var absPt = bgMoveArea.area2absolute(areaPt)
                    privateProps.actualFavorite.itemObject.position = Qt.point(absPt.x, absPt.y)
                }

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
