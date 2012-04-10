#ifndef SPLITADVANCEDSCENARIO_H
#define SPLITADVANCEDSCENARIO_H


#include "objectinterface.h"
#include "airconditioning_device.h"

#include <QObject>


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
		\brief Gets the scenario type (basic or advanced)
	*/
	Q_PROPERTY(QString advanced READ isAdvanced CONSTANT)

	/*!
		\brief Enables or disables the scenario
	*/
	Q_PROPERTY(bool enable READ isEnabled WRITE setEnabled NOTIFY enabledChanged)

	/*!
		\brief Gets or sets the split mode
	*/
	Q_PROPERTY(Mode mode READ getMode WRITE setMode NOTIFY modeChanged)

	/*!
		\brief Gets the scenario name
	*/
	Q_PROPERTY(QString name READ getName CONSTANT)

	/*!
		\brief Gets or sets the split swing
	*/
	Q_PROPERTY(Swing swing READ getSwing WRITE setSwing NOTIFY swingChanged)

	/*!
		\brief Gets or sets the split temperature set point
	*/
	Q_PROPERTY(int setPoint READ getSetPoint WRITE setSetPoint NOTIFY setPointChanged)

	/*!
		\brief Gets or sets the split fan speed
	*/
	Q_PROPERTY(Speed speed READ getSpeed WRITE setSpeed NOTIFY speedChanged)

	Q_ENUMS(Mode)
	Q_ENUMS(Speed)
	Q_ENUMS(Swing)

public:
	explicit SplitAdvancedScenario(QString name,
								   QString key,
								   AdvancedAirConditioningDevice *d,
								   QString command,
								   QObject *parent = 0);

	// TODO I didn't find a better way... :(
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

	bool isAdvanced() const
	{
		return true;
	}

	bool isEnabled() const;
	void setEnabled(bool enable);
	Mode getMode() const;
	void setMode(Mode mode);
	Swing getSwing() const;
	void setSwing(Swing swing);
	int getSetPoint() const;
	void setSetPoint(int setPoint);
	Speed getSpeed() const;
	void setSpeed(Speed speed);

signals:
	void enabledChanged();
	void modeChanged();
	void swingChanged();
	void setPointChanged();
	void speedChanged();

public slots:
	void sendScenarioCommand();

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

private:
	QString command;
	AdvancedAirConditioningDevice *dev;
	bool enabled;
	QString key;
	QString name;
	AdvancedAirConditioningDevice::Status status;
};

#endif // SPLITADVANCEDSCENARIO_H
