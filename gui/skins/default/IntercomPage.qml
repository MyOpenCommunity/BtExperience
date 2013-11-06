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


/**
  \ingroup Core

  \brief The intercom management page.

  This page is responsible to manage incoming intercom calls. When an
  intercom call arrives, the EventManager shows it up.
  The page opens a popup containing the ControlCall component which is the
  true responsible of the call management. When call terminates, application
  resumes from the point of last execution.
  */
BasePage {
    id: page

    /** The C++ model object managing the intercom call */
    property variant callObject

    opacity: 0
    _pageName: "IntercomPage"

    Component {
        id: popupComponent
        ControlCall {
            id: popupControl
            callerMode: false // incoming calls
            onClosePopup: Stack.popPage()
        }
    }

    Behavior on opacity {
        NumberAnimation { duration: constants.alertTransitionDuration }
    }

    Component.onCompleted: {
        installPopup(popupComponent, {dataObject: page.callObject, state: "callFrom"})
        popupLoader.item.dataObject.callEnded.connect(popupLoader.item.callEndedCallBack)
    }
}
