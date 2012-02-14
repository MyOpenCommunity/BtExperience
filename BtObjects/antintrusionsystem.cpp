#include "antintrusionsystem.h"
#include "antintrusion_device.h"
#include "objectlistmodel.h"

#include "xml_functions.h"

#include <QDebug>
#include <QStringList>

#define CODE_TIMEOUT_SECS 10


AntintrusionZone::AntintrusionZone(int id, QString _name)
{
	zone_number = id;
	name = _name;
	partialized = true;
}

bool AntintrusionZone::getPartialization() const
{
	return partialized;
}

void AntintrusionZone::setPartialization(bool p, bool request_partialization)
{
	if (p != partialized)
	{
		partialized = p;
		emit partializationChanged();
		if (request_partialization)
			emit requestPartialization(zone_number, p);
	}
}


AntintrusionScenario::AntintrusionScenario(QString _name, QList<int> _scenario_zones, QList<AntintrusionZone*> _zones)
{
	name = _name;
	scenario_zones = _scenario_zones;
	zones = _zones;
	foreach (AntintrusionZone *z, zones)
		connect(z, SIGNAL(partializationChanged()), SLOT(verifySelection()));
	verifySelection(false);
}

QVariant AntintrusionScenario::data(int role) const
{
	QVariant v = ObjectInterface::data(role);

	if (v.isNull() && role == DescriptionRole)
		return getDescription();

	return v;
}

QHash<int, QByteArray> AntintrusionScenario::roleNames()
{
	QHash<int, QByteArray> names = ObjectInterface::roleNames();
	names[DescriptionRole] = "description";
	return names;
}

QString AntintrusionScenario::getDescription() const
{
	QStringList l;
	foreach (int z, scenario_zones)
		l << QString::number(z);

	return l.join(".");
}

void AntintrusionScenario::verifySelection(bool notify)
{
	QList<int> selected_zones;
	foreach (AntintrusionZone *z, zones)
		if (!z->getPartialization())
			selected_zones.append(z->getObjectId());

	bool s = (scenario_zones == selected_zones);
	if (notify && selected != s)
	{
		selected = s;
		emit selectionChanged();
	}
	else
		selected = s;
}

bool AntintrusionScenario::isSelected() const
{
	return selected;
}

void AntintrusionScenario::apply()
{
	foreach (AntintrusionZone *z, zones)
	{
		bool inserted = scenario_zones.contains(z->getObjectId());
		z->setPartialization(!inserted);
	}
}


AntintrusionSystem::AntintrusionSystem(AntintrusionDevice *d, QList<AntintrusionScenario*> _scenarios, QList<AntintrusionZone*> _zones) :
	zones(_zones),
	scenarios(_scenarios)
{
	current_scenario = -1;
	waiting_response = false;
	initialized = false;
	status = false;
	dev = d;
	connect(dev, SIGNAL(valueReceived(DeviceValues)), SLOT(valueReceived(DeviceValues)));
}

ObjectListModel *AntintrusionSystem::getScenarios() const
{
	ObjectListModel *items = new ObjectListModel;
	for (int i = 0; i < scenarios.length(); ++i)
		items->appendRow(scenarios[i]);

	items->setRoleNames();
	items->reparentObjects();

	return items;
}

ObjectListModel *AntintrusionSystem::getZones() const
{
	ObjectListModel *items = new ObjectListModel;
	for (int i = 0; i < zones.length(); ++i)
		items->appendRow(zones[i]);

	items->setRoleNames();
	items->reparentObjects();

	return items;
}

void AntintrusionSystem::valueReceived(const DeviceValues &values_list)
{
	DeviceValues::const_iterator it = values_list.constBegin();
	while (it != values_list.constEnd())
	{
		switch (it.key())
		{
		case AntintrusionDevice::DIM_SYSTEM_INSERTED:
		{
			bool inserted = it.value().toBool();
			if (!initialized)
			{
				initialized = true;
				status = inserted;
			}
			else
			{
				if (inserted == status)
				{
					if (waiting_response)
					{
						emit codeRefused();
						waiting_response = false;
					}
				}
				else
				{
					if (!status)
					{
						// TODO: delete all the old alarms
					}
					status = inserted;
					emit statusChanged();

					if (waiting_response)
					{
						emit codeAccepted();
						waiting_response = false;
					}
				}
			}
			break;
		}

		case AntintrusionDevice::DIM_ZONE_INSERTED:
		case AntintrusionDevice::DIM_ZONE_PARTIALIZED:
			foreach (AntintrusionZone *z, zones)
				if (z->getObjectId() == it.value().toInt())
					z->setPartialization(it.key() == AntintrusionDevice::DIM_ZONE_PARTIALIZED, false);
			break;
		case AntintrusionDevice::DIM_ANTIPANIC_ALARM:
		case AntintrusionDevice::DIM_INTRUSION_ALARM:
		case AntintrusionDevice::DIM_TAMPER_ALARM:
		case AntintrusionDevice::DIM_TECHNICAL_ALARM:
			//            emit alarmReceived();
			break;
		}

		++it;
	}
}

void AntintrusionSystem::handleCodeTimeout()
{
	if (!waiting_response) // we have already received the response
		return;

	qDebug() << "AntintrusionSystem -> code timeout";
	waiting_response = false;
	emit codeTimeout();
}

void AntintrusionSystem::requestPartialization(const QString &password)
{
	dev->setPartialization(password);
	waiting_response = true;
	QTimer::singleShot(CODE_TIMEOUT_SECS * 1000, this, SLOT(handleCodeTimeout()));
}

void AntintrusionSystem::toggleActivation(const QString &password)
{
	dev->toggleActivation(password);
	waiting_response = true;
}

QObject *AntintrusionSystem::getCurrentScenario() const
{
	foreach (AntintrusionScenario *s, scenarios)
	{
		if (s->isSelected())
			return s;
	}
	return 0;
}

AntintrusionSystem *createAntintrusionSystem(AntintrusionDevice *dev, const QDomNode &xml_node)
{
	QList<QPair<int, QString> > zone_list;
	foreach (const QDomNode &zone, getChildren(getChildWithName(xml_node, "zones"), "zone"))
	{
		QString name = getTextChild(zone, "name");
		QString s = getTextChild(zone, "num");
		bool ok;
		int z = s.toInt(&ok);
		if (!ok)
		{
			qWarning() << "Invalid zone number" << s << "for zone" << name;
			continue;
		}
		zone_list << qMakePair(z, name);
	}

	QList<AntintrusionZone *> zones;
	for (int i = 0; i < zone_list.length(); ++i)
	{
		AntintrusionZone *z = new AntintrusionZone(zone_list.at(i).first, zone_list.at(i).second);
		dev->partializeZone(zone_list.at(i).first, z->getPartialization()); // initialization
		QObject::connect(z, SIGNAL(requestPartialization(int,bool)), dev, SLOT(partializeZone(int,bool)));
		zones << z;
	}

	QList<AntintrusionScenario *> scenarios;
	foreach (const QDomNode &scenario, getChildren(getChildWithName(xml_node, "scenarios"), "scenario"))
	{
		QString name = getTextChild(scenario, "name");
		QList<int> scenario_zones;
		foreach (QString s, getTextChild(scenario, "zones").split(","))
		{
			bool ok;
			int z = s.toInt(&ok);
			if (!ok)
			{
				qWarning() << "Invalid zone" << z << "for the scenario:" << name;
				continue;
			}
			scenario_zones << z;
		}

		scenarios << new AntintrusionScenario(name, scenario_zones, zones);
	}

	AntintrusionSystem *system = new AntintrusionSystem(dev, scenarios, zones);

	// we need to connect each scenario to antitrusion system object, which
	// cannot be done above
	foreach (AntintrusionScenario *s, scenarios)
		QObject::connect(s, SIGNAL(selectionChanged()), system, SIGNAL(currentScenarioChanged()));

	return system;
}
