#ifndef SPLITBASICSCENARIO_H
#define SPLITBASICSCENARIO_H

/*!
	\defgroup AirConditioning Air conditioning
*/

#include "objectinterface.h"
#include "device.h" // DeviceValues
#include "objectmodel.h"

#include <QObject>
#include <QStringList>


class AirConditioningDevice;
class NonControlledProbeDevice;
class QDomNode;
class UiiMapper;
class ObjectDataModel;

QList<ObjectPair> parseSplitBasicScenario(const QDomNode &xml_node);
QList<ObjectPair> parseSplitBasicCommand(const QDomNode &xml_node, const UiiMapper &uii_map);
QList<ObjectPair> parseSplitBasicCommandGroup(const QDomNode &xml_node, QHash<int, QPair<QDomNode, QDomNode> > programs);


/*!
	\ingroup AirConditioning
	\brief Container for basic aplit program

	The program number is in the object id, the program name in the object name.
*/
class SplitBasicProgram : public ObjectInterface
{
	Q_OBJECT

public:
	SplitBasicProgram(const QString &name, int number);

	virtual int getObjectId() const { return program_number; }

private:
	int program_number;
};


// This subclass exists only to have the correct translation for the "off" string
class SplitBasicOffProgram : public SplitBasicProgram
{
	Q_OBJECT

public:
	SplitBasicOffProgram(int number) : SplitBasicProgram("", number) { }

	virtual QString getName() const { return tr("off"); }
};


/*!
	\ingroup AirConditioning
	\brief A basic split scenario

	A class to manage a basic scenario.

	The object id is \a ObjectInterface::IdSplitBasicScenario.
*/
class SplitBasicScenario : public DeviceObjectInterface
{
	friend class TestSplitScenarios;

	Q_OBJECT

	/*!
		\brief Gets or sets the actual program
	*/
	Q_PROPERTY(SplitBasicProgram *program READ getProgram WRITE setProgram NOTIFY programChanged)

	/*!
		\brief Gets the list of available programs
	*/
	Q_PROPERTY(ObjectDataModel *programs READ getPrograms CONSTANT)

	/*!
		\brief Gets the temperature of the slave probe
	*/
	Q_PROPERTY(int temperature READ getTemperature NOTIFY temperatureChanged)

	/*!
		\brief Returns if a temperature probe is associated with the split
	*/
	Q_PROPERTY(bool temperatureEnabled READ getTemperatureEnabled CONSTANT)

	/*!
		\brief Returns if the \a temperature property contains a value received from the probe.
	*/
	Q_PROPERTY(bool temperatureIsValid READ getTemperatureIsValid NOTIFY temperatureIsValidChanged)

public:
	explicit SplitBasicScenario(QString name, QString key, AirConditioningDevice *d,
			QString off_command, NonControlledProbeDevice *d_probe, QObject *parent = 0);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdSplitBasicScenario;
	}

	virtual QString getObjectKey() const
	{
		return key;
	}

	SplitBasicProgram *getProgram() const;
	void setProgram(SplitBasicProgram *program);
	ObjectDataModel *getPrograms() const;
	int getTemperature() const;
	bool getTemperatureEnabled() const;
	bool getTemperatureIsValid() const;

	Q_INVOKABLE void apply();

	void addProgram(SplitBasicProgram *program);
	void execute(SplitBasicProgram *program);

signals:
	void programChanged();
	void temperatureChanged();
	void temperatureIsValidChanged(bool isValid);

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

private:
	ObjectDataModel programs;
	AirConditioningDevice *dev;
	NonControlledProbeDevice *dev_probe;
	QString key;
	SplitBasicProgram *actual_program;
	int temperature;
	bool is_valid_temperature;
};

/*!
	\ingroup AirConditioning
	\brief Sends a command to a split
*/
class SplitBasicCommand : public ObjectInterface
{
	Q_OBJECT
public:
	SplitBasicCommand(QObject *parent = 0);

	virtual int getObjectId() const { return IdSplitBasicCommand; }

	void appendCommand(SplitBasicScenario *scenario, SplitBasicProgram *program);
	Q_INVOKABLE void execute();

private:
	QList<QPair<SplitBasicScenario *, SplitBasicProgram *> > commands;
};

/*!
	\ingroup AirConditioning
	\brief Sends commands to multiple splits
*/
class SplitBasicCommandGroup : public ObjectInterface
{
	Q_OBJECT
public:
	SplitBasicCommandGroup(QString name, QList<QPair<QString, SplitBasicProgram *> > commands);

	virtual int getObjectId() const { return IdSplitBasicGenericCommandGroup; }

	Q_INVOKABLE void apply();

private:
	QList<QPair<AirConditioningDevice *, SplitBasicProgram *> > commands;
};

#endif // SPLITBASICSCENARIO_H
