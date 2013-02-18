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
void parseSplitBasicCommand(const QDomNode &xml_node, const UiiMapper &uii_map);
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

	Q_INVOKABLE void apply();

	void addProgram(SplitBasicProgram *program);

signals:
	void programChanged();
	void temperatureChanged();

protected slots:
	virtual void valueReceived(const DeviceValues &values_list);

private:
	ObjectDataModel programs;
	AirConditioningDevice *dev;
	NonControlledProbeDevice *dev_probe;
	QString key;
	SplitBasicProgram *actual_program;
	int temperature;
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
