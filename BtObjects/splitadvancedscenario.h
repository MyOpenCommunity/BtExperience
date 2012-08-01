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
class QDomNode;
class UiiMapper;

QList<ObjectPair> parseSplitAdvancedScenario(const QDomNode &xml_node);
void parseSplitAdvancedCommand(const QDomNode &xml_node, const UiiMapper &uii_map);
QList<ObjectPair> parseSplitAdvancedCommandGroup(const QDomNode &xml_node, QHash<int, QPair<QDomNode, QDomNode> > programs);


/*!
	\ingroup AirConditioning
	\brief A program associated to an advanced split scenario

	A class to record data related to a program associated to a scenario.

	This class is based on \a AdvancedAirConditioningDevice::Status adding a
	string property to hold the program name. Redfines some enums so they can
	be exported to QML.
*/
class SplitAdvancedProgram : public QObject
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

	explicit SplitAdvancedProgram(
			QString name,
			Mode mode,
			int temperature,
			Speed speed,
			Swing swing,
			QObject *parent=0);

	explicit SplitAdvancedProgram(QObject *parent=0);

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
	Q_PROPERTY(SplitAdvancedProgram::Mode mode READ getMode WRITE setMode NOTIFY modeChanged)

	/*!
		\brief Gets the split swing
	*/
	Q_PROPERTY(SplitAdvancedProgram::Swing swing READ getSwing NOTIFY swingChanged)

	/*!
		\brief Gets or sets the split temperature set point
	*/
	Q_PROPERTY(int setPoint READ getSetPoint WRITE setSetPoint NOTIFY setPointChanged)

	/*!
		\brief Gets the minimum split temperature set point
	*/
	Q_PROPERTY(int setPointMin READ getSetPointMin CONSTANT)

	/*!
		\brief Gets the maximum split temperature set point
	*/
	Q_PROPERTY(int setPointMax READ getSetPointMax CONSTANT)

	/*!
		\brief Gets the split fan speed
	*/
	Q_PROPERTY(SplitAdvancedProgram::Speed speed READ getSpeed NOTIFY speedChanged)

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
								   QString off_command,
								   NonControlledProbeDevice *d_probe,
								   QList<int> modes,
								   QList<int> speeds,
								   QList<int> swings,
								   int setpoint_min, int setpoint_max,
								   QObject *parent = 0);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdSplitAdvancedScenario;
	}

	virtual QString getObjectKey() const
	{
		return key;
	}

	SplitAdvancedProgram::Mode getMode() const;
	void setMode(SplitAdvancedProgram::Mode mode);
	QString getProgram() const;
	void setProgram(QString program);
	QStringList getPrograms() const;
	SplitAdvancedProgram::Swing getSwing() const;
	int getSetPoint() const;
	void setSetPoint(int setPoint);
	int getSetPointMin() const;
	int getSetPointMax() const;
	SplitAdvancedProgram::Speed getSpeed() const;
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

	void addProgram(SplitAdvancedProgram *program);

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

	QString off_command;
	AdvancedAirConditioningDevice *dev;
	NonControlledProbeDevice *dev_probe;
	QString key;
	SplitAdvancedProgram actual_program; // name empty means custom programming
	QList<SplitAdvancedProgram *> program_list;
	int temperature, setpoint_min, setpoint_max;
	ChoiceList *modes;
	ChoiceList *speeds;
	ChoiceList *swings;

	QHash<int, QVariant> current, to_apply;
};


/*!
	\ingroup AirConditioning
	\brief Sends commands to multiple splits
*/
class SplitAdvancedCommandGroup : public ObjectInterface
{
public:
	SplitAdvancedCommandGroup(QString name, QList<QPair<QString, SplitAdvancedProgram *> > commands);

	virtual int getObjectId() const { return IdSplitAdvancedGenericCommandGroup; }

	Q_INVOKABLE void apply();

private:
	QList<QPair<AdvancedAirConditioningDevice *, SplitAdvancedProgram *> > commands;
};

#endif // SPLITADVANCEDSCENARIO_H
