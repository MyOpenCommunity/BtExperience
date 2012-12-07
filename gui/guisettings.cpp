#include "guisettings.h"
#include "xml_functions.h"
#include "xmlobject.h"
#include "configfile.h"
#include "main.h" // bt_global::config

#include <QDebug>
#include <QDateTime>
#include <QDate>
#include <QTime>
#include <QCoreApplication>
#include <QFileInfo>
#include <QDir>
#include <QTranslator>

#include <limits>


namespace
{
	enum Parsing
	{
		HomePageContainer = 17,

		CleanScreen = 14152,
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

	timezone = 0;
	skin = Clear;
	home_bg_image = QString();
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
	clean_screen_time = 10;

	foreach (QDomNode container, getChildren(configurations->getConfiguration(LAYOUT_FILE).documentElement(), "container"))
	{
		if (getIntAttribute(container, "id") == HomePageContainer)
		{
			skin = getIntAttribute(container, "img_type", 0) == 0 ? Clear : Dark;
			home_bg_image = getAttribute(container, "img");
			break;
		}
	}

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
		case CleanScreen:
			clean_screen_time = parseIntSetting(xml_obj, "clean_time") / 1000;
			break;
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

	foreach (QDomNode container, getChildren(configurations->getConfiguration(LAYOUT_FILE).documentElement(), "container"))
	{
		if (getIntAttribute(container, "id") == HomePageContainer)
		{
			setAttribute(container, "img_type", QString::number(s == Clear ? 0 : 1));
			break;
		}
	}
	configurations->saveConfiguration(LAYOUT_FILE);

	skin = s;
	emit skinChanged();
}

QString GuiSettings::getHomeBgImage() const
{
	// if a custom background exists, returns it
	if (!home_bg_image.isEmpty())
		return home_bg_image;

	// no custom background is set, choose a standard one based on actual skin
	if (getSkin() == Dark)
		return QString("images/home/home_dark.jpg");

	return QString("images/home/home.jpg");
}

void GuiSettings::setHomeBgImage(QString new_value)
{
	if (home_bg_image == new_value)
		return;

	foreach (QDomNode container, getChildren(configurations->getConfiguration(LAYOUT_FILE).documentElement(), "container"))
	{
		if (getIntAttribute(container, "id") == HomePageContainer)
		{
			setAttribute(container, "img", new_value);
			break;
		}
	}
	configurations->saveConfiguration(LAYOUT_FILE);

	home_bg_image = new_value;
	emit homeBgImageChanged();
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

int GuiSettings::getCleanScreenTime() const
{
	return clean_screen_time;
}

void GuiSettings::setCleanScreenTime(int seconds)
{
	if (seconds == clean_screen_time)
		return;
	clean_screen_time = seconds;
	emit cleanScreenTimeChanged();

	QDomDocument conf = configurations->getConfiguration(SETTINGS_FILE);
	setIntSetting(conf, CleanScreen, "clean_time", clean_screen_time * 1000);
	configurations->saveConfiguration(SETTINGS_FILE);
}
