import QtQuick 1.1
import "array.js" as Script
import BtObjects 1.0

QtObject {
	function initNames() {
		Script.container['CONFIG'] = []
		Script.container['CONFIG'][PlatformSettings.Dhcp] = qsTr("DHCP")
		Script.container['CONFIG'][PlatformSettings.Static] = qsTr("static IP address")

		Script.container['STATE'] = []
		Script.container['STATE'][PlatformSettings.Enabled] = qsTr("Connect")
		Script.container['STATE'][PlatformSettings.Disabled] = qsTr("Disconnect")

		Script.container['SCREEN_SAVER_TYPE'] = []
		Script.container['SCREEN_SAVER_TYPE'][GuiSettings.None] = qsTr("None")
		Script.container['SCREEN_SAVER_TYPE'][GuiSettings.Image] = qsTr("Image")
		Script.container['SCREEN_SAVER_TYPE'][GuiSettings.Text] = qsTr("Text")
		Script.container['SCREEN_SAVER_TYPE'][GuiSettings.DateTime] = qsTr("Date and Time")

		Script.container['TURN_OFF_DISPLAY_LIST'] = []
		Script.container['TURN_OFF_DISPLAY_LIST'][GuiSettings.Seconds_15] = qsTr("15 sec")
		Script.container['TURN_OFF_DISPLAY_LIST'][GuiSettings.Seconds_30] = qsTr("30 sec")
		Script.container['TURN_OFF_DISPLAY_LIST'][GuiSettings.Minutes_1] = qsTr("1 min")
		Script.container['TURN_OFF_DISPLAY_LIST'][GuiSettings.Minutes_2] = qsTr("2 min")
		Script.container['TURN_OFF_DISPLAY_LIST'][GuiSettings.Minutes_5] = qsTr("5 min")
		Script.container['TURN_OFF_DISPLAY_LIST'][GuiSettings.Minutes_10] = qsTr("10 min")
		Script.container['TURN_OFF_DISPLAY_LIST'][GuiSettings.Minutes_30] = qsTr("30 min")
		Script.container['TURN_OFF_DISPLAY_LIST'][GuiSettings.Hours_1] = qsTr("1 hour")
		Script.container['TURN_OFF_DISPLAY_LIST'][GuiSettings.Never] = qsTr("never")

		Script.container['SCREEN_SAVER_TIMEOUT'] = []
		Script.container['SCREEN_SAVER_TIMEOUT'][GuiSettings.Seconds_15] = qsTr("15 sec")
		Script.container['SCREEN_SAVER_TIMEOUT'][GuiSettings.Seconds_30] = qsTr("30 sec")
		Script.container['SCREEN_SAVER_TIMEOUT'][GuiSettings.Minutes_1] = qsTr("1 min")
		Script.container['SCREEN_SAVER_TIMEOUT'][GuiSettings.Minutes_2] = qsTr("2 min")
		Script.container['SCREEN_SAVER_TIMEOUT'][GuiSettings.Minutes_5] = qsTr("5 min")
		Script.container['SCREEN_SAVER_TIMEOUT'][GuiSettings.Minutes_10] = qsTr("10 min")
		Script.container['SCREEN_SAVER_TIMEOUT'][GuiSettings.Minutes_30] = qsTr("30 min")
		Script.container['SCREEN_SAVER_TIMEOUT'][GuiSettings.Hours_1] = qsTr("1 hour")
		Script.container['SCREEN_SAVER_TIMEOUT'][GuiSettings.Never] = qsTr("never") // not really used

		// TODO from here on, change  wrt to model developments

		Script.container['AUTO_UPDATE'] = []
		Script.container['AUTO_UPDATE'][0] = qsTr("Enabled")
		Script.container['AUTO_UPDATE'][1] = qsTr("Disabled")

		Script.container['FORMAT'] = []
		Script.container['FORMAT'][0] = qsTr("12h")
		Script.container['FORMAT'][1] = qsTr("24h")

		Script.container['DST'] = []
		Script.container['DST'][0] = qsTr("Enable")
		Script.container['DST'][1] = qsTr("Disable")

		Script.container['PASSWORD'] = []
		Script.container['PASSWORD'][0] = qsTr("Enable")
		Script.container['PASSWORD'][1] = qsTr("Disable")

		Script.container['TIMEZONE'] = []
		Script.container['TIMEZONE'][-2] = qsTr("GMT -2")
		Script.container['TIMEZONE'][-1] = qsTr("GMT -1")
		Script.container['TIMEZONE'][0] = qsTr("GMT 0")
		Script.container['TIMEZONE'][1] = qsTr("GMT +1")
		Script.container['TIMEZONE'][2] = qsTr("GMT +2")

		Script.container['LANGUAGE'] = []
		Script.container['LANGUAGE'][0] = qsTr("Italian")
		Script.container['LANGUAGE'][1] = qsTr("English")
		Script.container['LANGUAGE'][2] = qsTr("Spanish")
	}

	function get(context, id) {
		if (Script.container.length === 0)
			initNames()

		return Script.container[context][id]
	}
}
