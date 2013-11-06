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
import Components 1.0
import "js/Stack.js" as Stack
import "js/EventManager.js" as EventManager


/**
  \ingroup Core

  \brief Component for a generic page.

  This component implements all common features for generic pages.

  A page may have navigation buttons. These buttons let the user navigate
  to specific pages linked to this one. For example, if we are in a function
  page, we can navigate to the home page for functions or step back to the
  previous page and so on.

  A page has always the toolbar on the top. The toolbar is useful to navigate
  to the home page for the application or to specific functions.

  When recording a scenario, a confirmation bar appears immediately below the
  toolbar. It contains buttons to stop&save the scenario or to cancel the
  recording.
  */
BasePage {
    id: page

    /** type:ToolBar The toolbar on top of this page */
    property alias toolbar: toolbar
    /** type:NavigationBar The navigation bar on the left side of this page */
    property alias navigationBar: navigationBar
    /** type:string The text displayed vertically on the navigation bar */
    property alias text: navigationBar.text
    /** type:bool Is the back button shown? */
    property alias showBackButton: navigationBar.backButton
    /** type:bool Is the systems button shown? */
    property alias showSystemsButton: navigationBar.systemsButton
    /** type:bool Is the settings button shown? */
    property alias showSettingsButton: navigationBar.settingsButton
    /** type:bool Is the rooms button shown? */
    property alias showRoomsButton: navigationBar.roomsButton
    /** type:bool Is the multimedia button shown? */
    property alias showMultimediaButton: navigationBar.multimediaButton
    /** type:string The URL to show when clicking on the help toolbar button */
    property alias helpUrl: toolbar.helpUrl

    /**
      Called when home button on the toolbar is clicked.
      Default implementation navigates to home page.
      */
    function homeButtonClicked() {
        Stack.backToHome()
    }

    /**
      Called when back button on navigation bar is clicked.
      Default implementation navigates to previous page.
      */
    function backButtonClicked() {
        Stack.popPage()
    }

    /**
      Called when systems button on navigation bar is clicked.
      Default implementation does nothing.
      */
    function systemsButtonClicked() {
    }

    /**
      Called when settings button on navigation bar is clicked.
      Default implementation does nothing.
      */
    function settingsButtonClicked() {
    }

    /**
      Called when rooms button on navigation bar is clicked.
      Default implementation does nothing.
      */
    function roomsButtonClicked() {
    }

    /**
      Called when multimedia button on navigation bar is clicked.
      Default implementation does nothing.
      */
    function multimediaButtonClicked() {
    }

    ToolBar {
        id: toolbar
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        onHomeClicked: homeButtonClicked()
    }

    NavigationBar {
        id: navigationBar
        anchors {
            top: toolbar.bottom
            topMargin: constants.navbarTopMargin
            left: parent.left
            bottom: parent.bottom
        }
        backButton: true
        systemsButton: false
        settingsButton: false
        roomsButton: false
        multimediaButton: false

        onBackClicked: backButtonClicked()
        onSystemsClicked: systemsButtonClicked()
        onSettingsClicked: settingsButtonClicked()
        onRoomsClicked: roomsButtonClicked()
        onMultimediaClicked: multimediaButtonClicked()
    }

    ConfirmationBar {
        id: scenarioBar

        height: 45
        z: 2
        opacity: EventManager.eventManager.scenarioRecording ? 1.0 : 0.0
        anchors {
            top: toolbar.bottom
            topMargin: -12
            left: parent.left
            right: parent.right
        }
    }
}
