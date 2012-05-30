#ifndef ANTINTRUSIONSYSTEM_H
#define ANTINTRUSIONSYSTEM_H

#include "objectinterface.h"
#include "objectmodel.h"
#include "device.h" // DeviceValues

#include <QString>
#include <QDateTime>


class AntintrusionSystem;
class AntintrusionDevice;
class ObjectDataModel;
class QDomNode;


AntintrusionSystem *createAntintrusionSystem(AntintrusionDevice *dev, const QDomNode &xml_node);


class AntintrusionZone : public ObjectInterface
{
	Q_OBJECT
	Q_PROPERTY(bool partialization READ getPartialization WRITE setPartialization NOTIFY partializationChanged)
	Q_PROPERTY(int number READ getNumber CONSTANT)

public:
	AntintrusionZone(int id, QString name);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdAntintrusionZone;
	}

	virtual ObjectCategory getCategory() const
	{
		return ObjectInterface::Antintrusion;
	}

	int getNumber() const;

	bool getPartialization() const;
	void setPartialization(bool p, bool request_partialization = true);

signals:
	void partializationChanged();
	void requestPartialization(int zone_number, bool partialize);

private:
	int zone_number;
	bool partialized;
};


class AntintrusionScenario : public ObjectInterface
{
	Q_OBJECT

public:
	AntintrusionScenario(QString name, QList<int> scenario_zones, QList<AntintrusionZone*> zones);
	Q_PROPERTY(bool selected READ isSelected NOTIFY selectionChanged)
	Q_PROPERTY(QString description READ getDescription CONSTANT)

	virtual ObjectCategory getCategory() const
	{
		return ObjectInterface::Antintrusion;
	}

	// return the description of the scenario, used by the omonymous role
	Q_INVOKABLE QString getDescription() const;

	// apply the scenario
	Q_INVOKABLE void apply();

	// check if the scenario is selected
	bool isSelected() const;

signals:
	void selectionChanged();

private slots:
	void verifySelection(bool notify = true);

private:
	QList<int> scenario_zones;
	QList<AntintrusionZone*> zones;
	bool selected;
};


class AntintrusionAlarm : public ObjectInterface
{
	Q_OBJECT
	Q_PROPERTY(AlarmType type READ getType CONSTANT)
	Q_PROPERTY(ObjectInterface *zone READ getZone CONSTANT)
	Q_PROPERTY(QDateTime date_time READ getDateTime CONSTANT)
	Q_ENUMS(AlarmType)

public:
	// Defined the same as AntintrusionDevice for convenience
	enum AlarmType
	{
		Antipanic,
		Intrusion,
		Tamper,
		Technical,
	};
	AntintrusionAlarm(AlarmType type, const AntintrusionZone *zone, QDateTime time);

	virtual ObjectCategory getCategory() const
	{
		return ObjectInterface::Antintrusion;
	}

	AlarmType getType();
	ObjectInterface *getZone();
	QDateTime getDateTime();

private:
	const AntintrusionZone *zone;
	AlarmType type;
	QDateTime date_time;
};


class AntintrusionSystem : public ObjectInterface
{
friend class TestAntintrusionSystem;

	Q_OBJECT
	Q_PROPERTY(ObjectDataModel *zones READ getZones CONSTANT)
	Q_PROPERTY(ObjectDataModel *scenarios READ getScenarios CONSTANT)
	Q_PROPERTY(ObjectDataModel *alarms READ getAlarms NOTIFY alarmsChanged)
	Q_PROPERTY(bool status READ getStatus NOTIFY statusChanged)
	Q_PROPERTY(QObject *currentScenario READ getCurrentScenario NOTIFY currentScenarioChanged)

public:
	AntintrusionSystem(AntintrusionDevice *d, QList<AntintrusionScenario*> _scenarios, QList<AntintrusionZone*> _zones);

	virtual int getObjectId() const
	{
		return ObjectInterface::IdAntintrusionSystem;
	}

	virtual ObjectCategory getCategory() const
	{
		return ObjectInterface::Antintrusion;
	}

	ObjectDataModel *getZones() const;
	ObjectDataModel *getScenarios() const;
	ObjectDataModel *getAlarms() const;

	Q_INVOKABLE void requestPartialization(const QString &password);
	Q_INVOKABLE void toggleActivation(const QString &password);

	bool getStatus() const
	{
		return status;
	}

	QObject *getCurrentScenario() const;

signals:
	void alarmsChanged();
	void newAlarm(AntintrusionAlarm *alarm);

	void statusChanged();
	void currentScenarioChanged();

	void codeAccepted();
	void codeRefused();
	void codeTimeout();

private slots:
	virtual void valueReceived(const DeviceValues &values_list);
	void handleCodeTimeout();

private:
	void addAlarm(AntintrusionAlarm::AlarmType t, int zone_num);
	void removeAlarm(AntintrusionAlarm::AlarmType t, int zone_num);
	bool isDuplicateAlarm(AntintrusionAlarm::AlarmType t, int zone_num);
	AntintrusionDevice *dev;
	ObjectDataModel zones;
	ObjectDataModel scenarios;
	ObjectDataModel alarms;
	bool status;
	bool initialized;
	bool waiting_response;
	int current_scenario;
};


#endif // ANTINTRUSIONSYSTEM_H
