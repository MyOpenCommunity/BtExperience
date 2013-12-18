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
import "js/Stack.js" as Stack
import "js/navigation.js" as Navigation


/**
  \ingroup Core

  \brief The room page

  The room page shows all objects configured for that room. Is possible to
  navigate to all rooms in the same ground.
  */
Page {
    id: page

    /** the room we are showing */
    property variant room
    property variant names: translations
    /** the uii for the ground */
    property int floorUii

    // We can't use the image directly, because the configuration software
    // doesn't resize images that are smaller than the screen resolution, and
    // we don't want to stretch the image.
    // This code mimics what we already do when saving images from external
    // sources, centering the image with a black border around it.
    Rectangle {
        color: "black"
        anchors.fill: parent
        z: -1000
        Image {
            source: room.image
            anchors.centerIn: parent
        }
    }

    /**
      Called when rooms button on navigation bar is clicked.
      Navigates back to rooms main page.
      */
    function roomsButtonClicked() {
        Stack.backToRoomOrHome()
    }

    /**
      Called when settings button on navigation bar is clicked.
      Navigates to settings page for this room.
      */
    function settingsButtonClicked() {
        Stack.goToPage("Settings.qml", {navigationTarget: Navigation.ROOM_SETTINGS, navigationData: [floorUii, room]})
    }

    /**
      Called when back button on navigation bar is clicked.
      Navigates back to room main page.
      */
    function backButtonClicked() {
        Stack.backToRoomOrHome()
    }

    text: room.description
    showBackButton: true
    showRoomsButton: true
    showSettingsButton: true

    Names {
        id: translations
    }

    MediaModel {
        source: myHomeModels.objectLinks
        id: roomModel
        containers: [room.uii]
        onContainersChanged: page.state = ""
    }

    MediaModel {
        source: myHomeModels.rooms
        id: roomsModel
        containers: [floorUii]
    }

    RoomView {
        id: roomCustomView

        anchors {
            left: navigationBar.right
            leftMargin: 20
            right: parent.right
            rightMargin: 20
            top: toolbar.bottom
            bottom: bottomRoomsView.top
        }
        pageObject: page
        model: roomModel
    }

    HorizontalView {
        id: bottomRoomsView
        anchors {
            left: navigationBar.right
            leftMargin: parent.width / 100
            right: parent.right
            rightMargin: parent.width / 100
            bottom: parent.bottom
        }
        height: 110
        model: roomsModel
        selectedIndex: findCurrentIndex()
        delegate: Image {
            id: listDelegate

            property variant itemObject: bottomRoomsView.model.getObject(index)

            source: bottomRoomsView.selectedIndex === index ? "images/common/stanzaS.png" : "images/common/stanza.png"

            Image {
                source: itemObject.cardImageCached
                fillMode: Image.PreserveAspectCrop
                clip: true
                width: page.width / 100 * 11.3
                height: page.height / 100 * 11.7
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -page.width / 100 * 0.2

                BeepingMouseArea {
                    id: clickMouseArea
                    anchors.fill: parent
                    onClicked: {
                        bottomRoomsView.selectedIndex = index
                        page.room = roomsModel.getObject(index)
                    }
                }

                Rectangle {
                    color: "black"
                    opacity: 0.7
                    anchors.fill: parent
                    visible: clickMouseArea.pressed
                }
            }
        }
    }

    function findCurrentIndex() {
        for (var i = 0; i < roomsModel.count; ++i)
            if (roomsModel.getObject(i).uii === room.uii)
                    return i;

        return 0;
    }
}
