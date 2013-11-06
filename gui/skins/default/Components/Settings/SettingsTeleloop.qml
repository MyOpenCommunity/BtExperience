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
import Components.Text 1.0


MenuColumn {
    id: column
    ObjectModel {
        id: vctModel
        filters: [{objectId: ObjectInterface.IdCCTV}]
    }

    QtObject {
        id: privateProps
        property variant model: vctModel.getObject(0)
    }

    SvgImage {
        id: bg
        source: "../../images/common/bg_panel_212x100.svg"

        ButtonThreeStates {
            id: associate
            text: qsTr("Associate")
            defaultImage: "../../images/common/btn_84x35.svg"
            pressedImage: "../../images/common/btn_84x35_P.svg"
            selectedImage: "../../images/common/btn_84x35_S.svg"
            shadowImage: "../../images/common/btn_shadow_84x35.svg"
            anchors {
                top: parent.top
                topMargin: bg.height / 100 * 5
                left: parent.left
                leftMargin: bg.width / 100 * 3
                right: parent.right
                rightMargin: bg.width / 100 * 3
            }
            enabled: !privateProps.model.teleloopAssociating
            onPressed: privateProps.model.startTeleloopAssociation()
        }

        UbuntuMediumText {
            text: privateProps.model.associatedTeleloopId ? qsTr("Associated") : qsTr("Not associated")
            anchors {
                top: associate.bottom
                topMargin: bg.height / 100 * 20
                horizontalCenter: parent.horizontalCenter
            }
            font.pixelSize: 15
        }
    }
}
