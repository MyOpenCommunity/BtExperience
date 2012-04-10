#ifndef SPLITBASICSCENARIO_H
#define SPLITBASICSCENARIO_H


#include "objectinterface.h"
#include "airconditioning_device.h"

#include <QObject>


/*!
	\ingroup Air Conditioning
	\brief A basic split scenario

	A class to manage the list of basic scenarios linked to a particular split.

	The object id is \a ObjectInterface::IdSplitBasicScenario.
*/
class SplitBasicScenario : public ObjectInterface
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
		\brief Gets the scenario name
	*/
	Q_PROPERTY(QString name READ getName CONSTANT)

public:
	explicit SplitBasicScenario(QString name,
								QString key,
								AirConditioningDevice *d,
								QString command,
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

	bool isAdvanced() const
	{
		return false;
	}

	bool isEnabled() const;
	void setEnabled(bool enable);

signals:
	void enabledChanged();

public slots:
	void sendScenarioCommand();

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

private:
	QString command;
	AirConditioningDevice *dev;
	bool enabled;
	QString key;
	QString name;
};

#endif // SPLITBASICSCENARIO_H
