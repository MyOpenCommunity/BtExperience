#ifndef SPLITADVANCEDSCENARIO_H
#define SPLITADVANCEDSCENARIO_H


#include "objectinterface.h"
#include "airconditioning_device.h"

#include <QObject>
#include <QStringList>


/*!
	\ingroup Air Conditioning
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
	enum Mode {
		ModeOff = AdvancedAirConditioningDevice::MODE_OFF,
		ModeWinter = AdvancedAirConditioningDevice::MODE_WINTER,
		ModeSummer = AdvancedAirConditioningDevice::MODE_SUMMER,
		ModeFan = AdvancedAirConditioningDevice::MODE_FAN,
		ModeDehumidification = AdvancedAirConditioningDevice::MODE_DEHUM,
		ModeAuto = AdvancedAirConditioningDevice::MODE_AUTO
	};

	enum Speed {
		SpeedAuto = AdvancedAirConditioningDevice::VEL_AUTO,
		SpeedMin = AdvancedAirConditioningDevice::VEL_MIN,
		SpeedMed = AdvancedAirConditioningDevice::VEL_MED,
		SpeedMax = AdvancedAirConditioningDevice::VEL_MAX,
		SpeedSilent = AdvancedAirConditioningDevice::VEL_SILENT,
		SpeedInvalid = AdvancedAirConditioningDevice::VEL_INVALID
	};

	enum Swing {
		SwingOff = AdvancedAirConditioningDevice::SWING_OFF,
		SwingOn = AdvancedAirConditioningDevice::SWING_ON,
		SwingInvalid = AdvancedAirConditioningDevice::SWING_INVALID
	};

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
	\ingroup Air Conditioning
	\brief An advanced split scenario

	A class to manage an advanced scenario.

	The object id is \a ObjectInterface::IdSplitAdvancedScenario.
*/
class SplitAdvancedScenario : public ObjectInterface
{
	Q_OBJECT

	/*!
		\brief Gets or sets the split mode
	*/
	Q_PROPERTY(SplitProgram::Mode mode READ getMode WRITE setMode NOTIFY modeChanged)

	/*!
		\brief Gets the split name
	*/
	Q_PROPERTY(QString name READ getName CONSTANT)

	/*!
		\brief Gets or sets the split swing
	*/
	Q_PROPERTY(SplitProgram::Swing swing READ getSwing WRITE setSwing NOTIFY swingChanged)

	/*!
		\brief Gets or sets the split temperature set point
	*/
	Q_PROPERTY(int setPoint READ getSetPoint WRITE setSetPoint NOTIFY setPointChanged)

	/*!
		\brief Gets or sets the split fan speed
	*/
	Q_PROPERTY(SplitProgram::Speed speed READ getSpeed WRITE setSpeed NOTIFY speedChanged)

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
	Q_PROPERTY(int size READ getSize CONSTANT)

public:
	explicit SplitAdvancedScenario(QString name,
								   QString key,
								   AdvancedAirConditioningDevice *d,
								   QString command,
								   QObject *parent = 0);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdSplitAdvancedScenario;
	}

	virtual QString getObjectKey() const
	{
		return key;
	}

	virtual ObjectCategory getCategory() const
	{
		// TODO Is thermal regulation right?
		return ObjectInterface::ThermalRegulation;
	}

	virtual QString getName() const
	{
		return name;
	}

	SplitProgram::Mode getMode() const;
	void setMode(SplitProgram::Mode mode);
	QString getProgram() const;
	void setProgram(QString program);
	QStringList getPrograms() const;
	SplitProgram::Swing getSwing() const;
	void setSwing(SplitProgram::Swing swing);
	int getSetPoint() const;
	void setSetPoint(int setPoint);
	SplitProgram::Speed getSpeed() const;
	void setSpeed(SplitProgram::Speed speed);
	int getSize() const;

	Q_INVOKABLE void ok();
	Q_INVOKABLE void resetProgram();

signals:
	void modeChanged();
	void programChanged();
	void swingChanged();
	void setPointChanged();
	void speedChanged();

public slots:
	void sendScenarioCommand();
	void sendOffCommand();

private:
	QString command;
	AdvancedAirConditioningDevice *dev;
	QString key;
	QString name;
	SplitProgram actual_program; // name empty means custom programming
	QList<SplitProgram *> program_list;
};

#endif // SPLITADVANCEDSCENARIO_H
