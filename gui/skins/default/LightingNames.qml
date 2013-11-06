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
import "js/array.js" as Script


/**
  \ingroup Lighting

  \brief Translations for the Lighting system.
  */
QtObject {
    // internal function to load values into the container
    function _init(container) {
        container['FIXED_TIMING'] = []
        /*
          Due to bug https://bugreports.qt-project.org/browse/QTBUG-21672
          we have to trick the -1 value. See also comment in lightobjects.h
          to FixedTimingType enum
          */
        container['FIXED_TIMING'][/*Light.FixedTimingDisabled*/ -1] = qsTr("Disabled")
        container['FIXED_TIMING'][Light.FixedTimingMinutes1] = qsTr("1 Minute")
        container['FIXED_TIMING'][Light.FixedTimingMinutes2] = qsTr("2 Minutes")
        container['FIXED_TIMING'][Light.FixedTimingMinutes3] = qsTr("3 Minutes")
        container['FIXED_TIMING'][Light.FixedTimingMinutes4] = qsTr("4 Minutes")
        container['FIXED_TIMING'][Light.FixedTimingMinutes5] = qsTr("5 Minutes")
        container['FIXED_TIMING'][Light.FixedTimingMinutes15] = qsTr("15 Minutes")
        container['FIXED_TIMING'][Light.FixedTimingSeconds30] = qsTr("30 Seconds")
        container['FIXED_TIMING'][Light.FixedTimingSeconds0_5] = qsTr("0.5 Seconds")
    }

    /**
      Retrieves the requested value from the local array.
      @param type:string context The translation context to distinguish between similar id.
      @param type:int id The id referring to the string to be translated.
      */
    function get(context, id) {
        if (Script.container.length === 0)
            _init(Script.container)

        return Script.container[context][id]
    }
}
