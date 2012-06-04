#ifndef SPLITBASICSCENARIO_H
#define SPLITBASICSCENARIO_H

/*!
	\defgroup AirConditioning Air conditioning
*/

#include "objectinterface.h"
#include "device.h" // DeviceValues

#include <QObject>
#include <QStringList>


class AirConditioningDevice;
class NonControlledProbeDevice;


/*!
	\ingroup AirConditioning
	\brief A basic split scenario

	A class to manage a basic scenario.

	The object id is \a ObjectInterface::IdSplitBasicScenario.
*/
class SplitBasicScenario : public ObjectInterface
{
	friend class TestSplitScenarios;

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
		\brief Gets the number of available programs (off is considered in the count)
	*/
	Q_PROPERTY(int count READ getCount CONSTANT)

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

	QString getProgram() const;
	void setProgram(QString program);
	QStringList getPrograms() const;
	int getCount() const;
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
	QString actual_program;
	QStringList program_list;
	int temperature;
};

#endif // SPLITBASICSCENARIO_H
