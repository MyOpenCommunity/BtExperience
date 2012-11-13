#ifndef GUISETTINGS_H
#define GUISETTINGS_H

#include <QObject>

class ConfigFile;


class GuiSettings : public QObject
{
	Q_OBJECT

	/*!
		\brief Sets or gets the brightness level of the display.
	*/
	Q_PROPERTY(int brightness READ getBrightness WRITE setBrightness NOTIFY brightnessChanged)

	/*!
		\brief Sets or gets the contrast level of the display.
	*/
	Q_PROPERTY(int contrast READ getContrast WRITE setContrast NOTIFY contrastChanged)

	/*!
		\brief Sets or gets the currency.
	*/
	Q_PROPERTY(Currency currency READ getCurrency WRITE setCurrency NOTIFY currencyChanged)

	/*!
		\brief Sets or gets the keyboard layout.
	*/
	Q_PROPERTY(QString keyboardLayout READ getKeyboardLayout WRITE setKeyboardLayout NOTIFY keyboardLayoutChanged)

	/*!
		\brief Sets or gets the language for the interface.
	*/
	Q_PROPERTY(QString language READ getLanguage WRITE setLanguage NOTIFY languageChanged)

	/*!
		\brief Sets or gets the skin for the interface.
	*/
	Q_PROPERTY(Skin skin READ getSkin WRITE setSkin NOTIFY skinChanged)

	/*!
		\brief Sets or gets the number separators for thousands and between
		integral and fractional part.
	*/
	Q_PROPERTY(NumberSeparators numberSeparators READ getNumberSeparators WRITE setNumberSeparators NOTIFY numberSeparatorsChanged)

	/*!
		\brief Sets or gets the unit used for temperature in Celsius or Fahrenheit.
	*/
	Q_PROPERTY(TemperatureUnit temperatureUnit READ getTemperatureUnit WRITE setTemperatureUnit NOTIFY temperatureUnitChanged)

	/*!
		\brief Sets or gets the timezone.
	*/
	Q_PROPERTY(int timezone READ getTimezone WRITE setTimezone NOTIFY timezoneChanged)
	// TODO use an enum for all managed timezones

	/*!
		\brief Sets or gets the beep status.
	*/
	Q_PROPERTY(bool beep READ getBeep WRITE setBeep NOTIFY beepChanged)

	/*!
		\brief Sets or gets energy threshold beep status.
	*/
	Q_PROPERTY(bool energyThresholdBeep READ getEnergyThresholdBeep WRITE setEnergyThresholdBeep NOTIFY energyThresholdBeepChanged)

	/*!
		\brief Sets or gets energy consumption pop-up status.
	*/
	Q_PROPERTY(bool energyPopup READ getEnergyPopup WRITE setEnergyPopup NOTIFY energyPopupChanged)

	/*!
		\brief Sets or gets burglar alarm alert.
	*/
	Q_PROPERTY(bool burglarAlarmAlert READ getBurglarAlarmAlert WRITE setBurglarAlarmAlert NOTIFY burglarAlarmAlertChanged)

	/*!
		\brief Sets or gets alarm clock alert.
	*/
	Q_PROPERTY(bool alarmClockAlert READ getAlarmClockAlert WRITE setAlarmClockAlert NOTIFY alarmClockAlertChanged)

	/*!
		\brief Sets or gets hands free alert.
	*/
	Q_PROPERTY(bool handsFreeAlert READ getHandsFreeAlert WRITE setHandsFreeAlert NOTIFY handsFreeAlertChanged)

	/*!
		\brief Sets or gets professional studio alert.
	*/
	Q_PROPERTY(bool professionalStudioAlert READ getProfessionalStudioAlert WRITE setProfessionalStudioAlert NOTIFY professionalStudioAlertChanged)

	/*!
		\brief Sets or gets call exclusion alert.
	*/
	Q_PROPERTY(bool callExclusionAlert READ getCallExclusionAlert WRITE setCallExclusionAlert NOTIFY callExclusionAlertChanged)

	/*!
		\brief Sets or gets burglar alarm danger alert.
	*/
	Q_PROPERTY(bool burglarAlarmDangerAlert READ getBurglarAlarmDangerAlert WRITE setBurglarAlarmDangerAlert NOTIFY burglarAlarmDangerAlertChanged)

	/*!
		\brief Sets or gets volume alert.
	*/
	Q_PROPERTY(bool volumeAlert READ getVolumeAlert WRITE setVolumeAlert NOTIFY volumeAlertChanged)

	/*!
		\brief Sets or gets player alert.
	*/
	Q_PROPERTY(bool playerAlert READ getPlayerAlert WRITE setPlayerAlert NOTIFY playerAlertChanged)

	/*!
		\brief Sets or gets the message alert.
	*/
	Q_PROPERTY(bool messageAlert READ getMessageAlert WRITE setMessageAlert NOTIFY messageAlertChanged)

	/*!
		\brief Sets or gets the scenario recording.
	*/
	Q_PROPERTY(bool scenarioRecordingAlert READ getScenarioRecordingAlert WRITE setScenarioRecordingAlert NOTIFY scenarioRecordingAlertChanged)

	Q_ENUMS(Currency)
	Q_ENUMS(NumberSeparators)
	Q_ENUMS(TemperatureUnit)
	Q_ENUMS(Skin)

public:
	explicit GuiSettings(QObject *parent = 0);

	enum Currency
	{
		CHF,
		EUR,
		GBP,
		JPY,
		USD
	};

	enum Skin
	{
		Clear,
		Dark
	};

	enum NumberSeparators
	{
		// TODO define meaningful values
		Dot_Comma,
		Comma_Dot
	};

	enum TemperatureUnit
	{
		Celsius,
		Fahrenheit
	};

	// brightness must be [1, 100]
	int getBrightness() const;
	void setBrightness(int b);
	// contrast must be [1, 100]
	int getContrast() const;
	void setContrast(int c);
	Currency getCurrency() const;
	void setCurrency(Currency c);
	QString getKeyboardLayout() const;
	void setKeyboardLayout(QString l);
	QString getLanguage() const;
	void setLanguage(QString l);
	NumberSeparators getNumberSeparators() const;
	void setNumberSeparators(NumberSeparators s);
	TemperatureUnit getTemperatureUnit() const;
	void setTemperatureUnit(TemperatureUnit u);
	int getTimezone() const;
	void setTimezone(int z);
	Skin getSkin() const;
	void setSkin(Skin s);
	bool getBeep() const;
	void setBeep(bool beep);
	bool getEnergyThresholdBeep() const;
	void setEnergyThresholdBeep(bool enable);
	bool getEnergyPopup() const;
	void setEnergyPopup(bool enable);
	bool getBurglarAlarmAlert() const;
	void setBurglarAlarmAlert(bool enable);
	bool getAlarmClockAlert() const;
	void setAlarmClockAlert(bool enable);
	bool getHandsFreeAlert() const;
	void setHandsFreeAlert(bool enable);
	bool getProfessionalStudioAlert() const;
	void setProfessionalStudioAlert(bool enable);
	bool getCallExclusionAlert() const;
	void setCallExclusionAlert(bool enable);
	bool getBurglarAlarmDangerAlert() const;
	void setBurglarAlarmDangerAlert(bool enable);
	bool getVolumeAlert() const;
	void setVolumeAlert(bool enable);
	bool getPlayerAlert() const;
	void setPlayerAlert(bool enable);
	bool getMessageAlert() const;
	void setMessageAlert(bool enable);
	bool getScenarioRecordingAlert() const;
	void setScenarioRecordingAlert(bool enable);

	QString getSkinString() const;

signals:
	void brightnessChanged();
	void contrastChanged();
	void currencyChanged();
	void keyboardLayoutChanged();
	void languageChanged();
	void numberSeparatorsChanged();
	void temperatureUnitChanged();
	void timezoneChanged();
	void skinChanged();
	void beepChanged();
	void energyThresholdBeepChanged();
	void energyPopupChanged();
	void burglarAlarmAlertChanged();
	void alarmClockAlertChanged();
	void handsFreeAlertChanged();
	void professionalStudioAlertChanged();
	void callExclusionAlertChanged();
	void burglarAlarmDangerAlertChanged();
	void volumeAlertChanged();
	void playerAlertChanged();
	void messageAlertChanged();
	void scenarioRecordingAlertChanged();

private:
	void parseSettings();
	void setSettingsEnableFlag(int id, bool enable);
	void setConfValue(QString path, QString value);

	ConfigFile *configurations;
	int brightness;
	int contrast;
	Currency currency;
	QString keyboardLayout;
	QString language;
	NumberSeparators numberSeparators;
	TemperatureUnit temperatureUnit;
	int timezone;
	Skin skin;
	bool beep;
	bool energy_threshold_beep;
	bool energy_popup;
	bool burglar_alarm_alert;
	bool alarm_clock_alert;
	bool hands_free_alert;
	bool professional_studio_alert;
	bool call_exclusion_alert;
	bool burglar_alarm_danger_alert;
	bool volume_alert;
	bool player_alert;
	bool message_alert;
	bool scenario_recording_alert;

private:
	void sendCommand(const QString &cmd);

};

#endif // GUISETTINGS_H
