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
            onClicked: column.dataModel.enabled = !column.dataModel.enabled
            status: !column.dataModel.enabled
        }

        ControlSettings {
            upperLabel: qsTr("triggers at")
            upperText: privateProps.formatTwoDigits(column.dataModel.hour) + ":" + privateProps.formatTwoDigits(column.dataModel.minute)
            bottomLabel: qsTr("repetition")
            bottomText: privateProps.formatRepetionString(qsTr("MTWTFSS"), [
                                                              column.dataModel.triggerOnMondays,
                                                              column.dataModel.triggerOnTuesdays,
                                                              column.dataModel.triggerOnWednesdays,
                                                              column.dataModel.triggerOnThursdays,
                                                              column.dataModel.triggerOnFridays,
                                                              column.dataModel.triggerOnSaturdays,
                                                              column.dataModel.triggerOnSundays
                                                          ],
                                                          column.dataModel.trigger)
            bottomTextFormat: Text.RichText
            onEditClicked: {
                column.closeColumn()
                Stack.pushPage("AlarmClockDateTimePage.qml", {"alarmClock": column.dataModel})
            }
        }

        ControlSettings {
            upperLabelVisible: false
            source: "../../images/termo/4-zone_temporizzato/bg_imposta-ora.svg"
            bottomLabel: qsTr("ringtone")
            bottomText: column.dataModel.alarmType === AlarmClock.AlarmClockBeep ? qsTr("beep") : qsTr("sound diffusion")
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

        function formatRepetionString(days, flags, trigger) {
            var result = ""

            for (var i = 0; i < 7; ++i)
                result += "<font color='" + (flags[i] ? "white" : "black") + "'>" + days[i] + "</font>"

            return result
        }
    }
}
