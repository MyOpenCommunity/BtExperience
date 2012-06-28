#ifndef SPLITADVANCEDSCENARIO_H
#define SPLITADVANCEDSCENARIO_H

/*!
	\defgroup AirConditioning Air conditioning
*/

#include "objectinterface.h"
#include "airconditioning_device.h"
#include "device.h" // DeviceValues

#include <QObject>
#include <QStringList>
#include <QHash>


class NonControlledProbeDevice;
class ChoiceList;


/*!
	\ingroup AirConditioning
	\brief A program associated to an advanced split scenario

	A class to record data related to a program associated to a scenario.

	This class is based on \a AdvancedAirConditioningDevice::Status adding a
	string property to hold the program name. Redfines some enums so they can
	be exported to QML.
*/
class SplitProgram : public QObject
{
	Q_OBJECT

	Q_ENUMS(Mode)
	Q_ENUMS(Speed)
	Q_ENUMS(Swing)

public:
	enum Mode
	{
		ModeOff = AdvancedAirConditioningDevice::MODE_OFF,
		ModeWinter = AdvancedAirConditioningDevice::MODE_WINTER,
		ModeSummer = AdvancedAirConditioningDevice::MODE_SUMMER,
		ModeFan = AdvancedAirConditioningDevice::MODE_FAN,
		ModeDehumidification = AdvancedAirConditioningDevice::MODE_DEHUM,
		ModeAuto = AdvancedAirConditioningDevice::MODE_AUTO
	};

	static Mode int2Mode(int v)
	{
		return static_cast<Mode>(v);
	}

	enum Speed
	{
		SpeedAuto = AdvancedAirConditioningDevice::VEL_AUTO,
		SpeedMin = AdvancedAirConditioningDevice::VEL_MIN,
		SpeedMed = AdvancedAirConditioningDevice::VEL_MED,
		SpeedMax = AdvancedAirConditioningDevice::VEL_MAX,
		SpeedSilent = AdvancedAirConditioningDevice::VEL_SILENT,
		SpeedInvalid = AdvancedAirConditioningDevice::VEL_INVALID
	};

	static Speed int2Speed(int v)
	{
		return static_cast<Speed>(v);
	}

	enum Swing
	{
		SwingOff = AdvancedAirConditioningDevice::SWING_OFF,
		SwingOn = AdvancedAirConditioningDevice::SWING_ON,
		SwingInvalid = AdvancedAirConditioningDevice::SWING_INVALID
	};

	static Swing int2Swing(int v)
	{
		return static_cast<Swing>(v);
	}

	explicit SplitProgram(
			QString name,
			Mode mode,
			int temperature,
			Speed speed,
			Swing swing,
			QObject *parent=0);

	explicit SplitProgram(QObject *parent=0);

	QString name;
	Mode mode;
	Speed speed;
	Swing swing;
	int temperature;
};


/*!
	\ingroup AirConditioning
	\brief An advanced split scenario

	A class to manage an advanced scenario.

	The object id is \a ObjectInterface::IdSplitAdvancedScenario.
*/
class SplitAdvancedScenario : public ObjectInterface
{
	friend class TestSplitScenarios;

	Q_OBJECT

	/*!
		\brief Gets or sets the split mode
	*/
	Q_PROPERTY(SplitProgram::Mode mode READ getMode WRITE setMode NOTIFY modeChanged)

	/*!
		\brief Gets the split swing
	*/
	Q_PROPERTY(SplitProgram::Swing swing READ getSwing NOTIFY swingChanged)

	/*!
		\brief Gets or sets the split temperature set point
	*/
	Q_PROPERTY(int setPoint READ getSetPoint WRITE setSetPoint NOTIFY setPointChanged)

	/*!
		\brief Gets the split fan speed
	*/
	Q_PROPERTY(SplitProgram::Speed speed READ getSpeed NOTIFY speedChanged)

	/*!
		\brief Gets or sets the actual program
	*/
	Q_PROPERTY(QString program READ getProgram WRITE setProgram NOTIFY programChanged)

	/*!
		\brief Gets the list of available programs
	*/
	Q_PROPERTY(QStringList programs READ getPrograms CONSTANT)

	/*!
		\brief Gets the size of available programs
	*/
	Q_PROPERTY(int count READ getCount CONSTANT)

	/*!
		\brief Gets the temperature of the slave probe
	*/
	Q_PROPERTY(int temperature READ getTemperature NOTIFY temperatureChanged)

	/*!
		\brief Gets the modes list
	*/
	Q_PROPERTY(QObject *modes READ getModes CONSTANT)

	/*!
		\brief Gets the speed values list
	*/
	Q_PROPERTY(QObject *speeds READ getSpeeds CONSTANT)

	/*!
		\brief Gets the swing values list
	*/
	Q_PROPERTY(QObject *swings READ getSwings CONSTANT)

public:
	explicit SplitAdvancedScenario(QString name,
								   QString key,
								   AdvancedAirConditioningDevice *d,
								   QString command,
								   NonControlledProbeDevice *d_probe,
								   QList<SplitProgram *> programs,
								   QList<int> modes,
								   QList<int> speeds,
								   QList<int> swings,
								   QObject *parent = 0);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdSplitAdvancedScenario;
	}

	virtual QString getObjectKey() const
	{
		return key;
	}

	SplitProgram::Mode getMode() const;
	void setMode(SplitProgram::Mode mode);
	QString getProgram() const;
	void setProgram(QString program);
	QStringList getPrograms() const;
	SplitProgram::Swing getSwing() const;
	int getSetPoint() const;
	void setSetPoint(int setPoint);
	SplitProgram::Speed getSpeed() const;
	int getCount() const;
	int getTemperature() const;
	QObject *getModes() const;
	QObject *getSpeeds() const;
	QObject *getSwings() const;

	Q_INVOKABLE void prevSpeed();
	Q_INVOKABLE void nextSpeed();
	Q_INVOKABLE void prevSwing();
	Q_INVOKABLE void nextSwing();
	Q_INVOKABLE void resetProgram();

signals:
	void modeChanged();
	void programChanged();
	void swingChanged();
	void setPointChanged();
	void speedChanged();
	void temperatureChanged();

public slots:
	void sendScenarioCommand();
	void sendOffCommand();
	void apply();
	void reset();

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

private:
	void sync();

	QString command;
	AdvancedAirConditioningDevice *dev;
	NonControlledProbeDevice *dev_probe;
	QString key;
	SplitProgram actual_program; // name empty means custom programming
	QList<SplitProgram *> program_list;
	int temperature;
	ChoiceList *modes;
	ChoiceList *speeds;
	ChoiceList *swings;

	QHash<int, QVariant> current, to_apply;
};

#endif // SPLITADVANCEDSCENARIO_H
