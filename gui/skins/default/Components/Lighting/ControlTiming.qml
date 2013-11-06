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


SvgImage {
    id: control

    property variant itemObject: undefined

    source: privateProps.isCustomTime() ? "../../images/common/bg_temporizzatore.svg" : "../../images/common/bg_temporizzatore_fisso.svg"

    QtObject {
        id: privateProps

        function isCustomTime() {
            var oid = itemObject.objectId

            if (oid === ObjectInterface.IdDimmer100CustomPP ||
                    oid === ObjectInterface.IdDimmer100CustomAMBGRGEN ||
                    oid === ObjectInterface.IdLightCustomPP ||
                    oid === ObjectInterface.IdLightCustomAMBGRGEN)
                return true

            return false
        }
    }

    UbuntuLightText {
        id: title
        color: "black"
        text: qsTr("timer")
        font.pixelSize: 15
        anchors {
            top: parent.top
            topMargin: 5
            left: parent.left
            leftMargin: 7
        }
    }

    Loader {
        id: timeLoader

        anchors {
            top: title.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        sourceComponent: privateProps.isCustomTime() ? customTimeComponent : fixedTimeComponent
    }

    Component {
        id: customTimeComponent

        Item {
            id: customFrame

            anchors.fill: parent

            UbuntuLightText {
                id: timing

                anchors {
                    verticalCenter: switchTiming.verticalCenter
                    left: parent.left
                    leftMargin: 7
                }
                font.pixelSize: 15
                color: "white"
                text: itemObject.timingEnabled ? qsTr("enabled") : qsTr("disabled")
            }

            Switch {
                id: switchTiming
                bgImage: "../../images/common/bg_cursore.svg"
                leftImageBg: "../../images/common/btn_temporizzatore_abilitato.svg"
                leftImage: "../../images/common/ico_temporizzatore_abilitato.svg"
                arrowImage: "../../images/common/ico_sposta_dx.svg"
                rightImageBg: "../../images/common/btn_temporizzatore_disabilitato.svg"
                rightImage: "../../images/common/ico_temporizzatore_disabilitato.svg"
                anchors {
                    top: parent.top
                    topMargin: 5
                    right: parent.right
                    rightMargin: 7
                }
                onPressed: itemObject.timingEnabled = !itemObject.timingEnabled
                status: !itemObject.timingEnabled
            }

            ControlDateTime {
                id: timingButtons
                anchors {
                    bottom: parent.bottom
                    bottomMargin: 11
                    left: parent.left
                    leftMargin: 7
                    right: parent.right
                    rightMargin: 7
                }
                enabled: itemObject.timingEnabled
                itemObject: control.itemObject
            }
        }
    }

    Component {
        id: fixedTimeComponent

        Item {
            id: customFrame

            anchors.fill: parent

            ControlLeftRight {
                id: fixedTimeControl

                anchors.fill: parent
                /*
                  Due to bug https://bugreports.qt-project.org/browse/QTBUG-21672
                  a -1 defined in enum is converted to undefined in QML
                  Bug will be solved in Qt 5, for now we have this hack
                */
                text: pageObject.names.get('FIXED_TIMING', itemObject.ftime === undefined ? -1 : itemObject.ftime)
                onLeftClicked: itemObject.prevFTime()
                onRightClicked: itemObject.nextFTime()
            }
        }
    }
}

