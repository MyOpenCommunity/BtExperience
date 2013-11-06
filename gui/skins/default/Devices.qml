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
import Components.Multimedia 1.0
import "js/Stack.js" as Stack


/**
  \ingroup Multimedia

  \brief A system page to show all available devices.

  This page shows all available devices like USB/SD or media servers.
  The user may browser inside devices and see file content.
  Clicking on a specific file the correspondent player is started.
  */
SystemPage {
    id: page

    property bool restoreBrowserState

    source: "images/background/devices.jpg"
    text: qsTr("Devices")
    rootColumn: Component { DevicesSystem { restoreBrowserState: page.restoreBrowserState } }
    showMultimediaButton: true
    showSystemsButton: false

    /**
      Called when multimedia button on navigation bar is clicked.
      Navigates back to multimedia page.
      */
    function multimediaButtonClicked() {
        Stack.backToMultimedia()
    }

    /**
      Hook called when MenuContainer is closed.
      Navigates back to multimedia page.
      */
    function systemPageClosed() {
        Stack.backToMultimedia()
    }
}
