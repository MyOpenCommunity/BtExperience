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
import "../../js/EventManager.js" as EventManager
import "../../js/Stack.js" as Stack


MenuColumn {
    id: column

    ObjectModel {
        id: objectModel
        filters: [{objectId: ObjectInterface.IdAlarmClock}]
    }

    Column {
        ControlSwitch {
            upperText: column.dataModel.description
            text: column.dataModel.enabled ? qsTr("enabled") : qsTr("disabled")
            onPressed: column.dataModel.enabled = !column.dataModel.enabled
            status: !column.dataModel.enabled
        }

        ControlSettings {
            upperLabel: qsTr("repetition")
            upperText: privateProps.formatRepetionString([
                                                             column.dataModel.triggerOnMondays,
                                                             column.dataModel.triggerOnTuesdays,
                                                             column.dataModel.triggerOnWednesdays,
                                                             column.dataModel.triggerOnThursdays,
                                                             column.dataModel.triggerOnFridays,
                                                             column.dataModel.triggerOnSaturdays,
                                                             column.dataModel.triggerOnSundays
                                                         ],
                                                         column.dataModel.trigger)
            upperTextFormat: Text.RichText
            bottomLabel: qsTr("triggers at")
            bottomText: privateProps.formatTwoDigits(column.dataModel.hour) + ":" + privateProps.formatTwoDigits(column.dataModel.minute)
            onEditClicked: {
                column.closeColumn()
                Stack.pushPage("AlarmClockDateTimePage.qml", {"alarmClock": column.dataModel})
            }
        }

        ControlSettings {
            upperLabelVisible: false
            source: "../../images/termo/4-zone_temporizzato/bg_imposta-ora.svg"
            bottomLabel: qsTr("ringtone")
            bottomText: column.dataModel.alarmType === AlarmClock.AlarmClockBeep ? qsTr("beep") : qsTr("Sound system")
            onEditClicked: {
                column.closeColumn()
                Stack.pushPage("AlarmClockRingtonePage.qml", {"alarmClock": column.dataModel})
            }
        }

        SvgImage {
            anchors.horizontalCenter: parent.horizontalCenter
            source: "../../images/termo/4-zone_temporizzato/bg_imposta-ora.svg"

            ButtonTextImageThreeStates {
                text: qsTr("DELETE")
                anchors.centerIn: parent
                defaultImageBg: "../../images/common/btn_cercapersone.svg"
                pressedImageBg: "../../images/common/btn_cercapersone_P.svg"
                shadowImage: "../../images/common/ombra_btn_cercapersone.svg"
                defaultImage: "../../images/common/ico_delete_p.svg"
                pressedImage: "../../images/common/ico_delete.svg"
                imageAnchors.rightMargin: 10

                onClicked: {
                    objectModel.remove(column.dataModel)
                    column.closeColumn()
                }
            }
        }
    }

    QtObject {
        id: privateProps

        function formatTwoDigits(value) {
            if (value < 10)
                value = "0" + value
            return value
        }

        function getDay(index) {
            if (index === 0)
                return qsTr("M", "Monday")
            else if (index === 1)
                return qsTr("T", "Tuesday")
            else if (index === 2)
                return qsTr("W", "Wednesday")
            else if (index === 3)
                return qsTr("T", "Thursday")
            else if (index === 4)
                return qsTr("F", "Friday")
            else if (index === 5)
                return qsTr("S", "Saturday")
            return qsTr("S", "Sunday")
        }

        function formatRepetionString(flags, trigger) {
            var result = ""

            for (var i = 0; i < 7; ++i)
                result += "<font color='" + (flags[i] ? "white" : "black") + "'>" + privateProps.getDay(i) + "</font>"

            return result
        }
    }
}
