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
import "../../js/logging.js" as Log
import Components 1.0


MenuColumn {
    id: column

    ObjectModel {
        id: objectModel
        filters: [{objectId: ObjectInterface.IdPlatformSettings}]
    }

    ObjectModel {
        id: vctModel
        filters: [{objectId: ObjectInterface.IdCCTV}]
    }

    QtObject {
        id: privateProps
        property variant model: objectModel.getObject(0)
    }

    Column {
        ControlTitleValue {
            title: qsTr("Firmware version")
            value: privateProps.model.firmwareVersion || qsTr("Unknown")
        }
        ControlTitleValue {
            title: qsTr("Kernel version")
            value: privateProps.model.kernelVersion || qsTr("Unknown")
        }
        ControlTitleValue {
            title: qsTr("Internal unit address")
            visible: vctModel.count > 0
            value: global.getPIAddress().slice(1) || qsTr("Unknown")
        }
        ControlTitleValue {
            title: qsTr("Associated entrance panel")
            visible: vctModel.count > 0
            value: global.defaultExternalPlace.where.slice(1) || qsTr("Unknown")
        }
        ControlTitleValue {
            title: qsTr("Multimedia source address")
            visible: global.multimediaSourceAddress !== ""
            value: global.multimediaSourceAddress
        }
    }
}
