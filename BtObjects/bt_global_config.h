#ifndef BT_GLOBAL_CONFIG_H
#define BT_GLOBAL_CONFIG_H


#include <QHash>


/// The default language used in the GUI
#define DEFAULT_LANGUAGE "en"

/// The file name to create for software watchdog
#define FILE_WDT "/var/tmp/bticino/bt_wd/BtExperience_qws"

/**
 * The following enum defines the keys of the global configuration.
 */
enum GlobalField
{
	LANGUAGE,
	TEMPERATURE_SCALE,
	DATE_FORMAT,
	MODEL,
	NAME,
	PI_ADDRESS,
	PI_MODE,
	GUARD_UNIT_ADDRESS,
	AMPLIFIER_ADDRESS,
	SOURCE_ADDRESS,
	TS_NUMBER,
	INIT_COMPLETE,
	DEFAULT_PE,
	USER_PASSWORD,
	USER_PASSWORD_ENABLED,
};

namespace bt_global {
	/// a global object to store global configuration parameters
	extern QHash<GlobalField, QString> *config;
}

enum TemperatureScale
{
	CELSIUS = 0,
	FAHRENHEIT,
};

enum DateFormat
{
	EUROPEAN_DATE = 0,   // dd.mm.yy
	USA_DATE = 1,        // mm.dd.yy
	YEAR_FIRST = 2       // yy.mm.dd
};


#endif // BT_GLOBAL_CONFIG_H
