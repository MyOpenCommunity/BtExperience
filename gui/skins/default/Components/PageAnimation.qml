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


/**
  Interface for page transition effects.

  It exposes four animations triggered by the Stack javascript manager.

  The page property must be set before calling the animations.
  */
Item {
    /** the page used as target for the animations */
    property Item page: null
    /** the duration of the animation effects */
    property int transitionDuration: 10
    /** a new page is being pushed into the stack and will become visible */
    property variant pushIn
    /** current page will be covered by a new page */
    property variant pushOut
    /** a page on stack will be shown */
    property variant popIn
    /** current page will be removed from stack and destroyed */
    property variant popOut

    /** must be called at animation end */
    signal animationCompleted
}
