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
    pushOut: animPushOut
    popIn: animPopIn
    popOut: animPopOut

    SequentialAnimation {
        id: animPushIn
        alwaysRunToEnd: true
        NumberAnimation { target: page; property: "opacity"; from: 0; to: 1; duration: transitionDuration }
        ScriptAction {
            script: animationCompleted()
        }
    }

    SequentialAnimation {
        id: animPushOut
        alwaysRunToEnd: true
        PropertyAction { target: page; property: "opacity"; value: 1 }
    }

    SequentialAnimation {
        id: animPopIn
        alwaysRunToEnd: true
        PropertyAction { target: page; property: "opacity"; value: 1 }
    }

    SequentialAnimation {
        id: animPopOut
        alwaysRunToEnd: true
        NumberAnimation { target: page; property: "opacity"; from: 1; to: 0; duration: transitionDuration }
        ScriptAction {
            script: animationCompleted()
        }
    }
}
