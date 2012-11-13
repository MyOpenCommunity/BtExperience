#include "guisettings.h"
#include "xml_functions.h"
#include "xmlobject.h"
#include "configfile.h"

#include <QDebug>
#include <QDateTime>
#include <QDate>
#include <QTime>
#include <QCoreApplication>
#include <QFileInfo>
#include <QDir>
#include <QTranslator>

#include <limits>

#if defined(BT_HARDWARE_X11)
#define CONF_FILE "conf.xml"
#define SETTINGS_FILE "settings.xml"
#else
#define CONF_FILE "/var/tmp/conf.xml"
#define SETTINGS_FILE "/home/bticino/cfg/extra/0/settings.xml"
#endif


namespace
{
	enum Parsing
	{
		EnergyThresholdBeep = 14255,
		EnergyConsumptionPopup = 14256,
		BurglarAlarmAlert = 14257,
		AlarmClockAlert = 14258,
		HandsFreeAlert = 14259,
		ProfessionalStudioAlert = 14260,
		CallExclusionAlert = 14261,
		BurglarAlarmDangerAlert = 14262,
		VolumeAlert = 14263,
		PlayerAlert = 14264,
		MessagesAlert = 14265,
		ScenarioRecordingAlert = 14266
	};

	void setEnableFlag(QDomDocument document, int id, bool enable)
	{
		foreach (const QDomNode &xml_obj, getChildren(document.documentElement(), "obj"))
		{
			if (getIntAttribute(xml_obj, "id") == id)
			{
				foreach (QDomNode ist, getChildren(xml_obj, "ist"))
					setAttribute(ist, "enable", QString::number(int(enable)));
				break;
			}
		}
	}

	bool parseEnableFlag(QDomNode xml_node)
	{
		bool result = false;
		XmlObject v(xml_node);

		foreach (const QDomNode &ist, getChildren(xml_node, "ist"))
		{
			v.setIst(ist);
			result = v.intValue("enable");
		}
		return result;
	}

	// Sets a language on the GUI; the GUI must be restarted for changes to have effect
	void setLanguageTranslator(QString language)
	{
		// language must be in the form it, en, ...
		static QTranslator *actual_translator = 0;
		// removes actual translation
		if (actual_translator)
		{
			QCoreApplication::instance()->removeTranslator(actual_translator);
			actual_translator = 0;
		}
		// computes new translation file name
		QFileInfo path = qApp->applicationDirPath();

	#ifdef Q_WS_MAC
		path = QFileInfo(QDir(path.absoluteFilePath()), "../Resources");
	#endif

		QString lf = QFileInfo(QDir(path.canonicalFilePath()),
			QString("gui/locale/bt_experience_%1").arg(language.toAscii().constData())).absoluteFilePath();

		// tries to install new translation
		actual_translator = new QTranslator();
		if (actual_translator->load(lf))
			QCoreApplication::instance()->installTranslator(actual_translator);
		else
		{
			actual_translator = 0;
			qWarning() << "File " << lf << " not found for language " << language;
		}
	}
}


GuiSettings::GuiSettings(QObject *parent) :
	QObject(parent)
{
	configurations = new ConfigFile(this);

	QDomDocument conf = configurations->getConfiguration(CONF_FILE);

	brightness = 50;
	contrast = 50;
	currency = "EUR";
	keyboardLayout = getConfValue(conf, "generale/keyboard_lang");
	numberSeparator = ".";
	temperatureUnit = Celsius;
	timezone = 0;
	skin = Clear;
	beep = false;
	energy_threshold_beep = false;
	energy_popup = false;
	burglar_alarm_alert = false;
	alarm_clock_alert = false;
	hands_free_alert = false;
	professional_studio_alert = false;
	call_exclusion_alert = false;
	burglar_alarm_danger_alert = false;
	volume_alert = false;
	player_alert = false;
	message_alert = false;
	scenario_recording_alert = false;
	language = getConfValue(conf, "generale/language");

	setLanguageTranslator(language);
	parseSettings();
}

void GuiSettings::parseSettings()
{
	QDomDocument document = configurations->getConfiguration(SETTINGS_FILE);

	foreach (const QDomNode &xml_obj, getChildren(document.documentElement(), "obj"))
	{
		int id = getIntAttribute(xml_obj, "id");

		switch (id)
		{
		case EnergyThresholdBeep:
			energy_threshold_beep = parseEnableFlag(xml_obj);
			break;
		case EnergyConsumptionPopup:
			energy_popup = parseEnableFlag(xml_obj);
			break;
		case BurglarAlarmAlert:
			burglar_alarm_alert = parseEnableFlag(xml_obj);
			break;
		case AlarmClockAlert:
			alarm_clock_alert = parseEnableFlag(xml_obj);
			break;
		case HandsFreeAlert:
			hands_free_alert = parseEnableFlag(xml_obj);
			break;
		case ProfessionalStudioAlert:
			professional_studio_alert = parseEnableFlag(xml_obj);
			break;
		case CallExclusionAlert:
			call_exclusion_alert = parseEnableFlag(xml_obj);
			break;
		case BurglarAlarmDangerAlert:
			burglar_alarm_danger_alert = parseEnableFlag(xml_obj);
			break;
		case VolumeAlert:
			volume_alert = parseEnableFlag(xml_obj);
			break;
		case PlayerAlert:
			player_alert = parseEnableFlag(xml_obj);
			break;
		case MessagesAlert:
			message_alert = parseEnableFlag(xml_obj);
			break;
		case ScenarioRecordingAlert:
			scenario_recording_alert = parseEnableFlag(xml_obj);
			break;
		}
	}
}

void GuiSettings::setSettingsEnableFlag(int id, bool enable)
{
	setEnableFlag(configurations->getConfiguration(SETTINGS_FILE), id, enable);
	configurations->saveConfiguration(SETTINGS_FILE);
}

void GuiSettings::setConfValue(QString path, QString value)
{
	::setConfValue(configurations->getConfiguration(CONF_FILE), path, value);
	configurations->saveConfiguration(CONF_FILE);
}

void GuiSettings::sendCommand(const QString &cmd)
{
	// TODO: add error check
	qDebug() << QString("GuiSettings::sendCommand(%1)").arg(cmd);
	system(qPrintable(cmd));
}

QString GuiSettings::getSkinString() const
{
	switch(skin)
	{
	case Clear:
		return QString("clear");
	case Dark:
		return QString("dark");
	default:
		return QString("clear");
	}
}

int GuiSettings::getBrightness() const
{
	return brightness;
}

void GuiSettings::setBrightness(int b)
{
	if (brightness == b)
		return;

	qDebug() << QString("GuiSettings::setBrightness(%1)").arg(b);
	// TODO: perform the proper conversion
	sendCommand(QString("i2cset -y 1 0x4a 0xf0 0x") + QString::number(b, 16));
	sendCommand(QString("i2cset -y 1 0x4a 0xf9 0x") + QString::number(b, 16));
	// TODO save value somewhere
	brightness = b;
	emit brightnessChanged();
}

int GuiSettings::getContrast() const
{
	return contrast;
}

void GuiSettings::setContrast(int c)
{
	if (contrast == c)
		return;

	qDebug() << QString("GuiSettings::setContrast(%1)").arg(c);
	// TODO save value somewhere
	contrast = c;
	emit contrastChanged();
}

QString GuiSettings::getCurrency() const
{
	return currency;
}

void GuiSettings::setCurrency(QString c)
{
	if (currency == c)
		return;

	// TODO save value somewhere
	currency = c;
	emit currencyChanged();
}

QString GuiSettings::getKeyboardLayout() const
{
	return keyboardLayout;
}

void GuiSettings::setKeyboardLayout(QString l)
{
	if (keyboardLayout == l)
		return;

	keyboardLayout = l;
	emit keyboardLayoutChanged();
	setConfValue("generale/keyboard_lang", l);
}

QString GuiSettings::getLanguage() const
{
	return language;
}

void GuiSettings::setLanguage(QString l)
{
	if (language == l)
		return;

	language = l;
	emit languageChanged();
	setConfValue("generale/language", language);
	setLanguageTranslator(language);
}

GuiSettings::Skin GuiSettings::getSkin() const
{
	return skin;
}

void GuiSettings::setSkin(Skin s)
{
	if (skin == s)
		return;

	// TODO save value somewhere
	skin = s;
	emit skinChanged();
}

bool GuiSettings::getBeep() const
{
	return beep;
}

void GuiSettings::setBeep(bool b)
{
	if (beep == b)
		return;

	beep = b;
	emit beepChanged();
}

QString GuiSettings::getNumberSeparator() const
{
       return numberSeparator;
}

void GuiSettings::setNumberSeparator(QString s)
{
       if (numberSeparator == s)
	       return;

       // TODO save value somewhere
       numberSeparator = s;
       emit numberSeparatorChanged();
}

GuiSettings::TemperatureUnit GuiSettings::getTemperatureUnit() const
{
	return temperatureUnit;
}

void GuiSettings::setTemperatureUnit(TemperatureUnit u)
{
	if (temperatureUnit == u)
		return;

	// TODO save value somewhere
	temperatureUnit = u;
	emit temperatureUnitChanged();
}

int GuiSettings::getTimezone() const
{
	return timezone;
}

void GuiSettings::setTimezone(int z)
{
	if (timezone == z)
		return;

	// TODO save value somewhere
	timezone = z;
	emit timezoneChanged();
}

bool GuiSettings::getEnergyThresholdBeep() const
{
	return energy_threshold_beep;
}

void GuiSettings::setEnergyThresholdBeep(bool enable)
{
	if (energy_threshold_beep == enable)
		return;
	energy_threshold_beep = enable;
	emit energyThresholdBeepChanged();
	setSettingsEnableFlag(EnergyThresholdBeep, enable);
}

bool GuiSettings::getEnergyPopup() const
{
	return energy_popup;
}

void GuiSettings::setEnergyPopup(bool enable)
{
	if (energy_popup == enable)
		return;
	energy_popup = enable;
	emit energyPopupChanged();
	setSettingsEnableFlag(EnergyConsumptionPopup, enable);
}

bool GuiSettings::getBurglarAlarmAlert() const
{
	return burglar_alarm_alert;
}

void GuiSettings::setBurglarAlarmAlert(bool enable)
{
	if (burglar_alarm_alert == enable)
		return;
	burglar_alarm_alert = enable;
	emit burglarAlarmAlertChanged();
	setSettingsEnableFlag(BurglarAlarmAlert, enable);
}

bool GuiSettings::getAlarmClockAlert() const
{
	return alarm_clock_alert;
}

void GuiSettings::setAlarmClockAlert(bool enable)
{
	if (alarm_clock_alert == enable)
		return;
	alarm_clock_alert = enable;
	emit alarmClockAlertChanged();
	setSettingsEnableFlag(AlarmClockAlert, enable);
}

bool GuiSettings::getHandsFreeAlert() const
{
	return hands_free_alert;
}

void GuiSettings::setHandsFreeAlert(bool enable)
{
	if (hands_free_alert == enable)
		return;
	hands_free_alert = enable;
	emit handsFreeAlertChanged();
	setSettingsEnableFlag(HandsFreeAlert, enable);
}

bool GuiSettings::getProfessionalStudioAlert() const
{
	return professional_studio_alert;
}

void GuiSettings::setProfessionalStudioAlert(bool enable)
{
	if (professional_studio_alert == enable)
		return;
	professional_studio_alert = enable;
	emit professionalStudioAlertChanged();
	setSettingsEnableFlag(ProfessionalStudioAlert, enable);
}

bool GuiSettings::getCallExclusionAlert() const
{
	return call_exclusion_alert;
}

void GuiSettings::setCallExclusionAlert(bool enable)
{
	if (call_exclusion_alert == enable)
		return;
	call_exclusion_alert = enable;
	emit callExclusionAlertChanged();
	setSettingsEnableFlag(CallExclusionAlert, enable);
}

bool GuiSettings::getBurglarAlarmDangerAlert() const
{
	return burglar_alarm_danger_alert;
}

void GuiSettings::setBurglarAlarmDangerAlert(bool enable)
{
	if (burglar_alarm_danger_alert == enable)
		return;
	burglar_alarm_danger_alert = enable;
	emit burglarAlarmDangerAlertChanged();
	setSettingsEnableFlag(BurglarAlarmDangerAlert, enable);
}

bool GuiSettings::getVolumeAlert() const
{
	return volume_alert;
}

void GuiSettings::setVolumeAlert(bool enable)
{
	if (volume_alert == enable)
		return;
	volume_alert = enable;
	emit volumeAlertChanged();
	setSettingsEnableFlag(VolumeAlert, enable);
}

bool GuiSettings::getPlayerAlert() const
{
	return player_alert;
}

void GuiSettings::setPlayerAlert(bool enable)
{
	if (player_alert == enable)
		return;
	player_alert = enable;
	emit playerAlertChanged();
	setSettingsEnableFlag(VolumeAlert, enable);
}

bool GuiSettings::getMessageAlert() const
{
	return message_alert;
}

void GuiSettings::setMessageAlert(bool enable)
{
	if (message_alert == enable)
		return;
	message_alert = enable;
	emit messageAlertChanged();
	setSettingsEnableFlag(MessagesAlert, enable);
}

bool GuiSettings::getScenarioRecordingAlert() const
{
	return scenario_recording_alert;
}

void GuiSettings::setScenarioRecordingAlert(bool enable)
{
	if (scenario_recording_alert == enable)
		return;
	scenario_recording_alert = enable;
	emit scenarioRecordingAlertChanged();
	setSettingsEnableFlag(ScenarioRecordingAlert, enable);
}
