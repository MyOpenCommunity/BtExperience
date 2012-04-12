#ifndef SPLITBASICSCENARIO_H
#define SPLITBASICSCENARIO_H


#include "objectinterface.h"
#include "device.h" // DeviceValues

#include <QObject>
#include <QStringList>


class AirConditioningDevice;
class NonControlledProbeDevice;

/*!
	\ingroup Air Conditioning
	\brief A basic split scenario

	A class to manage a basic scenario.

	The object id is \a ObjectInterface::IdSplitBasicScenario.
*/
class SplitBasicScenario : public ObjectInterface
{
	Q_OBJECT

	/*!
		\brief Gets or sets the actual program
	*/
	Q_PROPERTY(QString program READ getProgram WRITE setProgram NOTIFY programChanged)

	/*!
		\brief Gets the list of available programs
	*/
	Q_PROPERTY(QStringList programs READ getPrograms CONSTANT)

	/*!
		\brief Gets the scenario name
	*/
	Q_PROPERTY(QString name READ getName CONSTANT)

	/*!
		\brief Gets the number of available programs (off is considered in the count)
	*/
	Q_PROPERTY(int size READ getSize CONSTANT)

	/*!
		\brief Gets the temperature of the slave probe
	*/
	Q_PROPERTY(int temperature READ getTemperature NOTIFY temperatureChanged)

public:
	explicit SplitBasicScenario(QString name,
								QString key,
								AirConditioningDevice *d,
								QString command,
								QString off_command,
								NonControlledProbeDevice *d_probe,
								QStringList programs,
								QObject *parent = 0);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdSplitBasicScenario;
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

	QString getProgram() const;
	void setProgram(QString program);
	QStringList getPrograms() const;
	int getSize() const;
	int getTemperature() const;

	Q_INVOKABLE void ok();

signals:
	void programChanged();
	void temperatureChanged();

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

protected:
	void sendScenarioCommand();
	void sendOffCommand();

private:
	QString command;
	AirConditioningDevice *dev;
	NonControlledProbeDevice *dev_probe;
	QString key;
	QString name;
	QString actual_program;
	QStringList program_list;
	int temperature;
};

#endif // SPLITBASICSCENARIO_H
