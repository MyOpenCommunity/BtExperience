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

PageAnimation {
    pushIn: animPushIn
    popIn: animPopIn

    SequentialAnimation {
        id: animPushIn
        alwaysRunToEnd: true
        PropertyAction { target: page; property: "z"; value: 1 }
        NumberAnimation { target: page; property: "x"; from: 1024; to: 0; duration: transitionDuration }

        PropertyAction { target: page; property: "z"; value: 0 }
        ScriptAction {
            script: animationCompleted()
        }
    }

    SequentialAnimation {
        id: animPopIn
        alwaysRunToEnd: true
        PropertyAction { target: page; property: "z"; value: 1 }
        NumberAnimation { target: page; property: "x"; from: -1024; to: 0; duration: transitionDuration }

        PropertyAction { target: page; property: "z"; value: 0 }
        ScriptAction {
            script: animationCompleted()
        }
    }
}
