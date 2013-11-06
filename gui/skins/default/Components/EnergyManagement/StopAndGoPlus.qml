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
    id: element

    Column {
        SvgImage {
            source: "../../images/common/bg_panel_212x100.svg"

            ControlSwitch {
                text: qsTr("Auto close")
                pixelSize: 14
                onPressed: element.dataModel.autoReset = !element.dataModel.autoReset
                status: !element.dataModel.autoReset
                enabled: element.dataModel.status === StopAndGo.Closed
            }

            ButtonThreeStates {
                id: openButton

                defaultImage: "../../images/common/btn_99x35.svg"
                pressedImage: "../../images/common/btn_99x35_P.svg"
                selectedImage: "../../images/common/btn_99x35_S.svg"
                shadowImage: "../../images/common/btn_shadow_99x35.svg"
                text: qsTr("open")
                font.pixelSize: 15
                onPressed: element.dataModel.open()
                anchors {
                    left: parent.left
                    leftMargin: 7
                    bottom: parent.bottom
                    bottomMargin: parent.height / 100 * 7
                }
            }

            ButtonThreeStates {
                id: closeButton

                defaultImage: "../../images/common/btn_99x35.svg"
                pressedImage: "../../images/common/btn_99x35_P.svg"
                selectedImage: "../../images/common/btn_99x35_S.svg"
                shadowImage: "../../images/common/btn_shadow_99x35.svg"
                text: qsTr("close")
                font.pixelSize: 15
                onPressed: element.dataModel.close()
                anchors {
                    right: parent.right
                    rightMargin: 7
                    bottom: parent.bottom
                    bottomMargin: parent.height / 100 * 7
                }
            }
        }

        ControlSwitch {
            visible: element.dataModel.status === StopAndGo.Opened
            upperText: qsTr("Check Faults")
            text: element.dataModel.diagnostic ? qsTr("Enabled") : qsTr("Disabled")
            pixelSize: 14
            onPressed: element.dataModel.diagnostic = !element.dataModel.diagnostic
            status: !element.dataModel.diagnostic
            enabled: element.dataModel.status !== StopAndGo.Closed
        }
    }
}
